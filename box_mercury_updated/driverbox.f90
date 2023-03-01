PROGRAM KPP_ROOT_Driver

  USE KPP_ROOT_Model
  USE KPP_ROOT_Initialize, ONLY: Initialize

      KPP_REAL :: T, DVAL(NSPEC)
      KPP_REAL :: RSTATE(20)
      INTEGER :: i, TIMEFLAG1, TIMEFLAG2
!~~~> Initialization 
        
      STEPMIN = 0.0d0
      STEPMAX = 0.0d0

      DO i=1,NVAR
        RTOL(i) = 1.0d-4
        ATOL(i) = 1.0d-3
      END DO
     
      CALL InitSaveData_Box()           !Initialise output file
      CALL SaveSpeciesName_Box()        !Save names of species to be outputed
      CALL Initialize()                 !Initialise concentrations from .def file 
      
    !Create output file for photolysis rates
    open(UNIT=2, file='outputs/photolysis_rates.csv')
    WRITE(2,8886) 'Time', 'O1D', 'O3P', 'H2O2', 'NO2', 'N03=NO+O2', 'NO3=NO2+O', 'HONO', 'HNO3', &
                    'J9', 'J10', 'HCHO=H+CHO', 'HCHO=H2+CO','CH3CHO=CH3+HCO', 'C2H5CHO', &
                    'C3H7CHO=n-C3H7+HCO', 'C3H7CHO=C2H4+CH3CHO', 'IPRCHO', 'MACR-CH2=CCH3+HCO', &
                    'MACR-CH2=C(CH3)CO+H', 'J20', 'CH3COCH3-C', 'MEK', 'MVK-CH3CH=CH2+CO', &
                    'MVK-CH3CO+CH2=CH', 'J25', 'J26', 'J27', 'J28', 'J29', 'J30', 'GLYOX=CO+CO+H2', &
                    'GLYOX=HCHO+CO', 'GLYOX=HCO+HCO', 'MyGlox', 'BIACET', 'J36', 'J37', 'J38', &
                    'J39', 'J40', 'CH3OOH', 'J42', 'J43', 'J44', 'J45', 'J46', 'J47', 'J48', 'J49', &
                    'J50', 'CH3NO3', 'C2H5NO3', 'NC3H7NO3', 'IC3H7NO3', 'TC4H9NO3', &
                    'NOA=CH3C(O)CH2(O.)+NO2', 'NOA=CH3CO+HCHO+NO2', 'J58', 'J59', 'J60', 'I2', &
                    'IO', 'OIO', 'I2O2', 'I2O3', 'I2O4', 'I2O5', 'HOI', 'HI', 'INO', 'INO2', 'INO3', &
                    'IBr', 'ICl', 'CH3I', 'CH2I2', 'CH2ICl', 'CH2IBr', 'C2H5I', 'nC3H7I', 'iC3H7I', &
                    'Br2', 'BrO', 'HOBr', 'BrNO2', 'BrNO3', 'J87', 'J88', 'J89', 'HgBr', 'HgOH', &
                    'HgI', 'HgCl', 'HgCl2', 'HgBr2', 'HgBrOOH', 'HgBrOH', 'c-HgBrO', '3SHgO', '1SHgO', &
                    'HgBrNO2', 'HgBrOI', 'HgBrOBr', 'HgBrOCl', 'HgBrI', 't-HgBrONO', &
                    'HgOHCl', 'HgClO', 'JHg', 'J110', 'J111','J112', 'J113', 'J114','J115', 'J116', &
                    'J117', 'J118', 'J119', 'J120', 'jfactor', 'a', 'b'
                    
    8886 FORMAT(124(1x,A))
      
    T = TSTART
    TIME = 43200.
    CALL PHOTOLYSIS_RATES()
    J1_MAX = J(1)
    TIME = T 
    TIMEFLAG1 = 0
    TIMEFLAG2 = 10*60-INT(DT)
    CALL PHOTOLYSIS_RATES()       ! Calculate photolysis for the start time.
    !Fix concentrations according to constraints
    Call SET_CONCENTRATIONS()
    
kron: DO WHILE (T < TEND) !~~~> Time loop

        TIMEFLAG1 = TIMEFLAG1 + INT(DT)           !Set timeflag for output and photolysis calculation
        TIME = T

        !!Check if the timeflag for monitor, output and photolysis has been flagged.
        !! If yes, print the concentrations on the screen, file and calculate photolysis
        IF (TIMEFLAG1 >=60*60) THEN
            !Write on screen
            WRITE(6,991) (T-TSTART)/(TEND-TSTART)*100, T,       &
                   ( TRIM(SPC_NAMES(MONITOR(i))),           &
                     C(MONITOR(i))/CFACTOR, i=1,NMONITOR ), &
                   ( TRIM(SMASS(i)), DVAL(i)/CFACTOR, i=1,NMASS )
            
            CALL SaveData_Box()             !Write in output file 
            
            CALL PHOTOLYSIS_RATES()         !!Call photolysis subroutine in this file
            jfactor = J(1)/J1_MAX           !!Define JFACTOR for gaussian flux  
            factortime = TIME/(24*3600.D0)
            factortime = factortime - INT(factortime)
            !jfactor2 = sin(factortime*3.14+6.8)*cos(factortime*3.14)+0.6
            !IF (jfactor<0) THEN
            !jfactor2 = 0
            !END IF
            !jfactor = jfactor*jfactor2
            !jfactor2 =SIN((factortime*6))*jfactor
            !IF (jfactor2 < 0) THEN
            !    jfactor2 = 0
            !END IF
            !IF (jfactor>0) THEN
            !jfactor2 = jfactor2 + 1
            !END IF
            !jfactor = jfactor2*jfactor2
            jfactor2 = jfactor
            IF (jfactor2 > 0.6) THEN
                jfactor2 = 0.6
            END IF
            ! Write photolysis rates in an output file
            WRITE(2,8885) TIME/3600.D0, (J(i), i=1,120),jfactor,factortime,jfactor2
            8885   FORMAT(E24.16,124(1X,E24.16))
            TIMEFLAG1=0
            Call ROPA_RODA
        END IF
       
        Cair = PRESSURE
        CALL Update_RCONST()

        CALL INTEGRATE( TIN = T, TOUT = T+DT, RSTATUS_U = RSTATE, &
        ICNTRL_U = (/ 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 /) )
        T = RSTATE(1)
        
       !Fix concentrations according to constraints
       Call SET_CONCENTRATIONS()
       !Calculate the entrainment or ventilation into the FT
       !Call FT_EXCHANGE()

    END DO kron
!~~~> End Time loop
    
    !Write the final outputs
    WRITE(6,991) (T-TSTART)/(TEND-TSTART)*100, T,     &
               ( TRIM(SPC_NAMES(MONITOR(i))),           &
                 C(MONITOR(i))/CFACTOR, i=1,NMONITOR ), &
               ( TRIM(SMASS(i)), DVAL(i)/CFACTOR, i=1,NMASS )
    TIME = T
    CALL SaveData_Box()
    CALL CloseSaveData()
    CLOSE(2)        !Close photolysis output file

991 FORMAT(F6.1,'%. T=',E9.3,2X,200(A,'=',E11.4,'; '))

    CALL MAKE_PLOTS()
      
END PROGRAM KPP_ROOT_Driver

SUBROUTINE SET_CONCENTRATIONS ()
USE KPP_ROOT_Model
INTEGER :: i      ! Integer DO loops
    DO i=1,NSPEC
            IF (SPC_NAMES(i) == 'BrO') THEN 
                C(i)  = 6*CFACTOR*jfactor !/0.6
            END IF
             IF (SPC_NAMES(i) == 'Cl') THEN 
                C(i)  = 2.E-4*CFACTOR*jfactor
            END IF   
            IF (SPC_NAMES(i) == 'NO') THEN 
                C(i)  = 5*CFACTOR*jfactor
            END IF       
    END DO

END SUBROUTINE

SUBROUTINE FT_EXCHANGE ()
USE KPP_ROOT_Model

    REAL(kind=dp) :: FT_HgII,MBL_HgII,v_e,difference,RGMARRAY(13),tempo

  !  Calculate total HgII
	RGMARRAY(1) = C(ind_HgBr2) 
	RGMARRAY(2) = C(ind_HgBr) 
	RGMARRAY(3) = C(ind_HgBrOH) 
	RGMARRAY(4) = C(ind_HgI) 
	RGMARRAY(5) = C(ind_HgBrI) 
	RGMARRAY(6) = C(ind_HgCl) 
	RGMARRAY(7) = C(ind_HgCl2) 
	RGMARRAY(8) = C(ind_HgBrCl) 
	RGMARRAY(9) = C(ind_HgBrNO2) 
	RGMARRAY(10) = C(ind_HgBrHO2) 
	RGMARRAY(11) = C(ind_BrHgOBr) 
	RGMARRAY(12) = C(ind_BrHgOI) 
    RGMARRAY(13) = C(ind_HgO)
	
	MBL_HgII = 0.
	DO i=1,13
		IF (isnan(RGMARRAY(i))) THEN
			tempo = 1.	
		ELSE
			MBL_HgII = MBL_HgII + RGMARRAY(i)
		END IF
	END DO
	
    !Calculate the amount in the FT
    FT_HgII = (10.*22.45*CFACTOR)/(200.*1000.)

    !Calculate entrainment rate according to the BL height and the timestep!!
    v_e = 0.5*DT/H_alt
    
    !Calculate difference between MBL and FT
    difference = v_e*(FT_HgII-MBL_HgII)
    !difference = v_e*FT_HgII

    !Distribute the difference
    IF(MBL_HgII>0.) THEN
		C(ind_HgBrNO2) = C(ind_HgBrNO2)+ (difference*C(ind_HgBrNO2)/MBL_HgII)
		C(ind_HgBrHO2) = C(ind_HgBrHO2)+ (difference*C(ind_HgBrHO2)/MBL_HgII)
		C(ind_BrHgOBr) = C(ind_BrHgOBr)+ (difference*C(ind_BrHgOBr)/MBL_HgII)
		C(ind_BrHgOI) = C(ind_BrHgOI)+ (difference*C(ind_BrHgOI)/MBL_HgII)
		C(ind_HgBr2) = C(ind_HgBr2)+ (difference*C(ind_HgBr2)/MBL_HgII)
		C(ind_HgBr) = C(ind_HgBr)+ (difference*C(ind_HgBr)/MBL_HgII)
		C(ind_HgBrOH) = C(ind_HgBrOH)+ (difference*C(ind_HgBrOH)/MBL_HgII)
		C(ind_HgI) = C(ind_HgI)+ (difference*C(ind_HgI)/MBL_HgII)
		C(ind_HgBrI) = C(ind_HgBrI)+ (difference*C(ind_HgBrI)/MBL_HgII)
		C(ind_HgCl) = C(ind_HgCl)+ (difference*C(ind_HgCl)/MBL_HgII)
		C(ind_HgCl2) = C(ind_HgCl2)+ (difference*C(ind_HgCl2)/MBL_HgII)
		C(ind_HgBrCl) = C(ind_HgBrCl)+ (difference*C(ind_HgBrCl)/MBL_HgII)
		C(ind_HgO) = C(ind_HgO)+ (difference*C(ind_HgO)/MBL_HgII)
	END IF
	
END SUBROUTINE

SUBROUTINE PHOTOLYSIS_RATES ()
USE KPP_ROOT_Model
!~~~> Declarations DO 1D
      CHARACTER(len=100) :: Generic_Line
      INTEGER :: i, w, NP, PT, ICLD, IHT, ICDSW, ALSW, ZLT             ! Loop integers
      REAL(kind=dp) :: TOZ,TO3,  QTHETA, FIXTIM
      REAL(kind=dp) :: EPS, CALB
      REAL(kind=dp) :: RTD, DTR
      REAL(kind=dp) :: THETA, TAER, AMDIFF, COST
      REAL(kind=dp) :: REARTH, REFPT, HTU, HTL, SINSQ, UPPER, LOWER, AMDIR(51)
      REAL(kind=dp) :: ALBL, ALBFCT, CALBFCT
      REAL(kind=dp) :: R_wav_temp, quantum_flux_TEMP, CSO3_A_TEMP, CSO3_B_TEMP, CSH2O2_TEMP
      REAL(kind=dp) :: PHIH2O2_TEMP, CSNO2_TEMP, PHINO2_TEMP, CSNO3_TEMP, PHINO3_1_TEMP
      REAL(kind=dp) :: PHINO3_2_TEMP, CSHONO_TEMP, CSHNO3_A_TEMP, CSHNO3_B_TEMP, CSHCHO_298_TEMP
      REAL(kind=dp) :: CSHCHO_C_TEMP, PHIHCHO_1_TEMP, PHIHCHO_2_TEMP, CSCH3CHO_TEMP
      REAL(kind=dp) :: PHICH3CHO_1_TEMP, PHICH3CHO_2_TEMP, CSC2H5CHO_TEMP, PHIC2H5CHO_TEMP
      REAL(kind=dp) :: CSC3H7CHO_TEMP, PHIC3H7CHO_1_TEMP, PHIC3H7CHO_2_TEMP, CSIPRCHO_TEMP
      REAL(kind=dp) :: PHIPRCHO_TEMP, CSMACR_TEMP, PHIMACR_1_TEMP, PHIMACR_2_TEMP
      REAL(kind=dp) :: CSCH3COCH3_298_TEMP, CSCH3COCH3_A_TEMP, CSCH3COCH3_B_TEMP, CSCH3COCH3_C_TEMP
      REAL(kind=dp) :: PHICH3COCH3_1_TEMP, PHICH3COCH3_2_TEMP, CSMEK_TEMP, PHIMEK_TEMP, CSMVK_TEMP
      REAL(kind=dp) :: PHIMVK_1_TEMP, PHIMVK_2_TEMP, CSGLYOX_TEMP, PHIGLYOX_1_TEMP, PHIGLYOX_2_TEMP
      REAL(kind=dp) :: PHIGLYOX_3_TEMP, CSMYGLYOX_TEMP, PHIMYGLYOX_TEMP, CSBIACET_TEMP
      REAL(kind=dp) :: PHIBIACET_1_TEMP, CSCH3OOH_TEMP, CSCH3NO3_298_TEMP, CSCH3NO3_B_TEMP
      REAL(kind=dp) :: CSC2H5NO3_298_TEMP, CSC2H5NO3_B_TEMP, CSNC3H7NO3_TEMP, CSIC3H7NO3_298_TEMP
      REAL(kind=dp) :: CSIC3H7NO3_B_TEMP, CSTC4H9NO3_TEMP, CSNOA_TEMP, PHINOA_1_TEMP, PHINOA_2_TEMP
      REAL(kind=dp) :: CSI2_TEMP, CSIO_TEMP, CSOIO_TEMP, CSI2O2_TEMP, CSI2O3_TEMP, CSI2O4_TEMP
      REAL(kind=dp) :: CSI2O5_TEMP, CSHOI_TEMP, CSHI_TEMP, CSINO_TEMP, CSINO2_TEMP, CSINO3_TEMP, CSIBr_TEMP
      REAL(kind=dp) :: CSICl_TEMP, CSCH3I_TEMP, CSCH2I2_TEMP, CSCH2ICl_TEMP, CSCH2IBr_TEMP
      REAL(kind=dp) :: CSC2H5I_TEMP, CSnC3H7I_TEMP, CSiC3H7I_TEMP, CSBr2_TEMP, CSBrO_TEMP
      REAL(kind=dp) :: CSHOBr_TEMP, CSBrNO2_TEMP, CSBrNO3_TEMP
      REAL(kind=dp) :: CSHgBr_TEMP, CSHgI_TEMP, CSHgCl_TEMP, CSHgOH_TEMP
      REAL(kind=dp) :: CSHgCl2_TEMP ,CSHgBr2_TEMP,CSHgBrOOH_TEMP, CSHgBrOH_TEMP,CScisHgBRONO_TEMP ,CS3SHgO_TEMP 
      REAL(kind=dp) :: CS1SHgO_TEMP ,CSHgBrNO2_TEMP,CSHgBrOI_TEMP ,CSHgBrOBr_TEMP ,CSHgBrOCl_TEMP 
      REAL(kind=dp) :: CSHgBrI_TEMP ,CStransHgBrONO_TEMP,CSHgOHCl_TEMP ,CSHgClO_TEMP, CSHg_TEMP
      REAL(kind=dp) :: X1, X2, X3, W1, W2, W3, A1, A2, A3, V1, V2, C1, R1, Q1, Q2, GAUS1, GAUS2, GAUS3 
      REAL(kind=dp) :: R_wav(516), Q_phot(516), CSO3(516), CSO3_A(516), CSO3_B(516), PHIO3_1(516)
      REAL(kind=dp) :: PHIO3_2(516), CSH2O2(516), PHIH2O2(516), CSNO2(516), PHINO2(516), CSNO3(516)
      REAL(kind=dp) :: PHINO3_1(516), PHINO3_2(516), CSHONO(516), CSHNO3(516), CSHNO3_A(516), CSHNO3_B(516)
      REAL(kind=dp) :: CSHCHO(516),CSHCHO_298(516), CSHCHO_C(516), PHIHCHO_1(516), PHIHCHO_2(516) 
      REAL(kind=dp) :: CSCH3CHO(516), PHICH3CHO_1(516), PHICH3CHO_2(516), CSC2H5CHO(516), PHIC2H5CHO(516)
      REAL(kind=dp) :: CSC3H7CHO(516), PHIC3H7CHO_1(516), PHIC3H7CHO_2(516), CSIPRCHO(516), PHIIPRCHO(516)
      REAL(kind=dp) :: CSMACR(516), PHIMACR_1(516), PHIMACR_2(516), CSCH3COCH3(516), CSCH3COCH3_298(516) 
      REAL(kind=dp) :: CSCH3COCH3_A(516), CSCH3COCH3_B(516), CSCH3COCH3_C(516), PHICH3COCH3_1(516)
      REAL(kind=dp) :: PHICH3COCH3_2(516), CSMEK(516), PHIMEK(516), CSMVK(516), PHIMVK_1(516), PHIMVK_2(516)
      REAL(kind=dp) :: CSGLYOX(516), PHIGLYOX_1(516), PHIGLYOX_2(516), PHIGLYOX_3(516), CSMYGLYOX(516) 
      REAL(kind=dp) :: PHIMYGLYOX(516), CSBIACET(516), PHIBIACET_1(516), CSCH3OOH(516), CSCH3NO3(516)
      REAL(kind=dp) :: CSCH3NO3_298(516), CSCH3NO3_B(516), CSC2H5NO3(516), CSC2H5NO3_298(516)
      REAL(kind=dp) :: CSC2H5NO3_B(516), CSNC3H7NO3(516), CSIC3H7NO3(516), CSIC3H7NO3_298(516)
      REAL(kind=dp) :: CSIC3H7NO3_B(516), CSTC4H9NO3(516), CSNOA(516), PHINOA_1(516)
      REAL(kind=dp) :: PHINOA_2(516), CSI2(516), CSIO(516), CSOIO(516), CSI2O2(516), CSI2O3(516), CSI2O4(516)
      REAL(kind=dp) :: CSI2O5(516), CSHOI(516), CSHI(516), CSINO(516), CSINO2(516), CSINO3(516), CSIBr(516)
      REAL(kind=dp) :: CSICl(516), CSCH3I(516), CSCH2I2(516), CSCH2ICl(516), CSCH2IBr(516), CSC2H5I(516)
      REAL(kind=dp) :: CSnC3H7I(516), CSiC3H7I(516), CSBr2(516), CSBrO(516), CSHOBr(516), CSBrNO2(516)
      REAL(kind=dp) :: CSBrNO3(516), CSHgBr(516),CSHgI(516),CSHgOH(516),CSHgCl(516) ,CSHgCl2(516) ,CSHgBr2(516) 
      REAL(kind=dp) :: CSHgBrOOH(516),CSHgBrOH(516),CScisHgBRONO(516) ,CS3SHgO(516) ,CS1SHgO(516) ,CSHgBrNO2(516) 
      REAL(kind=dp) :: CSHgBrOI(516) ,CSHgBrOBr(516) ,CSHgBrOCl(516) ,CSHgBrI(516) ,CStransHgBrONO(516)
      REAL(kind=dp) :: CSHgOHCl(516) ,CSHgClO(516),CSHg(516)
      REAL(kind=dp) :: XEDM(51), RAT(51), XEDM_TEMP, RAT_TEMP, EDM(51)
      REAL(kind=dp) :: WN(516), CRS(516)
      INTEGER :: LAM, NWV1
      REAL(kind=dp) :: T1(51,516), T4(51,516), Z1(51,516), QRAD(51,516)
      
    DO i = 1, 120
        J(i) = 0
    END DO 
    
    !! Define initial constants used in photolysis    
    JDAY = 150      !Julian Day of Year
    LATITUDE = 75.63   !Latitude
    ZLT = 0         !Altitude of interest above sea level in km
    NP = 51 - 0     !Number of 1 km layers of atmosphere above surface
    IHT = 51 - ZLT  !Number of 1 km layers of atmosphere light must travel through
    TOZ = 270       !Ozone Column Density - Dobson Units
    TO3 = (TOZ / 1000) * (0.001 / 22.4) * AVOG !Ozone Column Density - molec. per cc

    !!Start Time Options
    PT = 0                  !IF constant zenith angle run, =1
    QTHETA = 0 * pi / 180   !Zenith angle (rad.) DO const. angle run
    FIXTIM = 0              !Fixed time trigger
   
    !!Integration Constants
    EPS = 0.000001          !Accuracy of integration
    
    !!Cloud and Albedo Switches
    ICDSW = 0               !Cloud switch 0 off, 1 on
    ICLD = NP - 1           !Number of 1 km layers of atmosphere above cloud base
    CALB = 0                !Cloud Albedo
    ALSW = 1                !Surface albedo switch 1 fixed, 0 = f(THETA)
    ALBL = 0.8              !Surface albedo DO fixed case
    
    RTD = 180 / pi          !Radians, degrees
    DTR = pi / 180          !Degrees, radians
    
    !!!!!!!!!!!!!!!!!!!!!!!!!
    !Main photolysis routine
    !Calculates and returns j-values
     
    !! Calculate SZA and see IF its necessary to run this routine
    
    Call check_SZA()
    IF (SZA > 95) THEN
        RETURN
    END IF
    
    IF (PT == 0) THEN      !IF not a const.zenith angle run, calculate it
        THETA = SZA*PI/180
        IF (FIXTIM < 0 .OR. FIXTIM > 0) THEN  ! KEEP IN UNLESS NEED TO CHANGE START TIME DO STEPPING RUNS
            THETA = QTHETA                                
        END IF
    ELSE IF (PT == 1) THEN
        THETA = QTHETA
    END IF
    
    !Aerosol optical thickness at the ground, (0 DO no aerosols)
    TAER = 0
 
    AMDIFF = 1.66
    COST = Cos(THETA)
    
    !Chapman Function Calculations DO AMDIR(direct)
    !using the ground as ref. level, from Dahlback
    !and Stamnes(1991), DO Earth radius use 6356.78
    !polar and 6378.16 DO equatorial
    
    REARTH = 6378.16
    REFPT = 0
    DO w= 1,NP        !Number of layers light passes through to get to ground level
        HTU = 51 - w + 1
        HTL = HTU - 1
        SINSQ = (Sin(THETA))**2
        UPPER = SQRT(((REARTH + HTU)**2) - ((REARTH + REFPT)**2) * SINSQ)
        LOWER = SQRT(((REARTH + HTL)**2) - ((REARTH + REFPT)**2) * SINSQ)
        AMDIR(w) = UPPER - LOWER    !cf. AMDIR = 1 / COST
    END DO
    
    ALBFCT = 2 * ALBL * COST        !Surface albedo
    CALBFCT = 2 * CALB * COST       !Cloud albedo
    IF (ICDSW == 0) THEN            !IF cloud switch is off, light path goes to surface
        ICLD = NP
    ELSE 
        ALBFCT = CALBFCT            !otherwise albedo is cloud albedo
        ALBL = CALB                 !surface albedo still AL
    END IF
    
    !! READ IN PHOTOLYSIS FILES AND CREATE THE RIGHT ARRAYS
    open(UNIT=1, file='inputs/photolysis_files/photolysis_data_updated.csv')
            READ (1, *) GENERIC_LINE
            READ (1, *) GENERIC_LINE
        DO i=1,516
            READ (1, *) R_wav_temp, quantum_flux_TEMP, CSO3_A_TEMP, CSO3_B_TEMP, CSH2O2_TEMP, &
                    PHIH2O2_TEMP, CSNO2_TEMP, PHINO2_TEMP, CSNO3_TEMP, PHINO3_1_TEMP, &
                    PHINO3_2_TEMP, CSHONO_TEMP, CSHNO3_A_TEMP, CSHNO3_B_TEMP, CSHCHO_298_TEMP, &
                    CSHCHO_C_TEMP, PHIHCHO_1_TEMP, PHIHCHO_2_TEMP, CSCH3CHO_TEMP, &
                    PHICH3CHO_1_TEMP, PHICH3CHO_2_TEMP, CSC2H5CHO_TEMP, PHIC2H5CHO_TEMP, &
                    CSC3H7CHO_TEMP, PHIC3H7CHO_1_TEMP, PHIC3H7CHO_2_TEMP, CSIPRCHO_TEMP, &
                    PHIPRCHO_TEMP, CSMACR_TEMP, PHIMACR_1_TEMP, PHIMACR_2_TEMP, &
                    CSCH3COCH3_298_TEMP, CSCH3COCH3_A_TEMP, CSCH3COCH3_B_TEMP, CSCH3COCH3_C_TEMP, &
                    PHICH3COCH3_1_TEMP, PHICH3COCH3_2_TEMP, CSMEK_TEMP, PHIMEK_TEMP, CSMVK_TEMP, &
                    PHIMVK_1_TEMP, PHIMVK_2_TEMP, CSGLYOX_TEMP, PHIGLYOX_1_TEMP, PHIGLYOX_2_TEMP, &
                    PHIGLYOX_3_TEMP, CSMYGLYOX_TEMP, PHIMYGLYOX_TEMP, CSBIACET_TEMP, &
                    PHIBIACET_1_TEMP, CSCH3OOH_TEMP, CSCH3NO3_298_TEMP, CSCH3NO3_B_TEMP, &
                    CSC2H5NO3_298_TEMP, CSC2H5NO3_B_TEMP, CSNC3H7NO3_TEMP, CSIC3H7NO3_298_TEMP, &
                    CSIC3H7NO3_B_TEMP, CSTC4H9NO3_TEMP, CSNOA_TEMP, PHINOA_1_TEMP, PHINOA_2_TEMP, &
                    CSI2_TEMP, CSIO_TEMP, CSOIO_TEMP, CSI2O2_TEMP, CSI2O3_TEMP, CSI2O4_TEMP, &
                    CSI2O5_TEMP, CSHOI_TEMP, CSHI_TEMP, CSINO_TEMP, CSINO2_TEMP, CSINO3_TEMP, &
                    CSIBr_TEMP, CSICl_TEMP, CSCH3I_TEMP, CSCH2I2_TEMP, CSCH2ICl_TEMP, CSCH2IBr_TEMP, &
                    CSC2H5I_TEMP, CSnC3H7I_TEMP, CSiC3H7I_TEMP, CSBr2_TEMP, CSBrO_TEMP, &
                    CSHOBr_TEMP, CSBrNO2_TEMP, CSBrNO3_TEMP, CSHgBr_TEMP, CSHgOH_TEMP, CSHgI_TEMP, &
                    CSHgCl_TEMP, CSHgCl2_TEMP ,CSHgBr2_TEMP,CSHgBrOOH_TEMP ,CSHgBrOH_TEMP ,CScisHgBRONO_TEMP, & 
                    CS3SHgO_TEMP, CS1SHgO_TEMP ,CSHgBrNO2_TEMP,CSHgBrOI_TEMP ,CSHgBrOBr_TEMP , & 
                    CSHgBrOCl_TEMP, CSHgBrI_TEMP ,CStransHgBrONO_TEMP,CSHgOHCl_temp, CSHgClO_temp, CSHg_temp
            R_wav(i) = R_wav_temp
            Q_phot(i) = quantum_flux_TEMP 
            CSO3_A(i) = CSO3_A_TEMP
            CSO3_B(i) = CSO3_B_TEMP
            CSH2O2(i) = CSH2O2_TEMP
            PHIH2O2(i) = PHIH2O2_TEMP
            CSNO2(i) = CSNO2_TEMP
            PHINO2(i) = PHINO2_TEMP
            CSNO3(i) = CSNO3_TEMP
            PHINO3_1(i) = PHINO3_1_TEMP
            PHINO3_2(i) = PHINO3_2_TEMP
            CSHONO(i) = CSHONO_TEMP
            CSHNO3_A(i) = CSHNO3_A_TEMP
            CSHNO3_B(i) = CSHNO3_B_TEMP
            CSHCHO_298(i) = CSHCHO_298_TEMP
            CSHCHO_C(i) = CSHCHO_C_TEMP
            PHIHCHO_1(i) = PHIHCHO_1_TEMP
            PHIHCHO_2(i) = PHIHCHO_2_TEMP
            CSCH3CHO(i) = CSCH3CHO_TEMP
            PHICH3CHO_1(i) = PHICH3CHO_1_TEMP
            PHICH3CHO_2(i) = PHICH3CHO_2_TEMP
            CSC2H5CHO(i) = CSC2H5CHO_TEMP
            PHIC2H5CHO(i) = PHIC2H5CHO_TEMP
            CSC3H7CHO(i) = CSC3H7CHO_TEMP
            PHIC3H7CHO_1(i) = PHIC3H7CHO_1_TEMP
            PHIC3H7CHO_2(i) = PHIC3H7CHO_2_TEMP
            CSIPRCHO(i) = CSIPRCHO_TEMP
            PHIIPRCHO(i) = PHIPRCHO_TEMP
            CSMACR(i) = CSMACR_TEMP
            PHIMACR_1(i) = PHIMACR_1_TEMP
            PHIMACR_2(i) = PHIMACR_2_TEMP
            CSCH3COCH3_298(i) = CSCH3COCH3_298_TEMP
            CSCH3COCH3_A(i) = CSCH3COCH3_A_TEMP
            CSCH3COCH3_B(i) = CSCH3COCH3_B_TEMP
            CSCH3COCH3_C(i) = CSCH3COCH3_C_TEMP
            PHICH3COCH3_1(i) = PHICH3COCH3_1_TEMP
            PHICH3COCH3_2(i) = PHICH3COCH3_2_TEMP
            CSMEK(i) = CSMEK_TEMP
            PHIMEK(i) = PHIMEK_TEMP
            CSMVK(i) = CSMVK_TEMP
            PHIMVK_1(i) = PHIMVK_1_TEMP
            PHIMVK_2(i) = PHIMVK_2_TEMP
            CSGLYOX(i) = CSGLYOX_TEMP
            PHIGLYOX_1(i) = PHIGLYOX_1_TEMP
            PHIGLYOX_2(i) = PHIGLYOX_2_TEMP
            PHIGLYOX_3(i) = PHIGLYOX_3_TEMP
            CSMYGLYOX(i) = CSMYGLYOX_TEMP
            PHIMYGLYOX(i) = PHIMYGLYOX_TEMP
            CSBIACET(i) = CSBIACET_TEMP
            PHIBIACET_1(i) = PHIBIACET_1_TEMP
            CSCH3OOH(i) = CSCH3OOH_TEMP
            CSCH3NO3_298(i) = CSCH3NO3_298_TEMP
            CSCH3NO3_B(i) = CSCH3NO3_B_TEMP
            CSC2H5NO3_298(i) = CSC2H5NO3_298_TEMP
            CSC2H5NO3_B(i) = CSC2H5NO3_B_TEMP
            CSNC3H7NO3(i) = CSNC3H7NO3_TEMP
            CSIC3H7NO3_298(i) = CSIC3H7NO3_298_TEMP
            CSIC3H7NO3_B(i) = CSIC3H7NO3_B_TEMP
            CSTC4H9NO3(i) = CSTC4H9NO3_TEMP
            CSNOA(i) = CSNOA_TEMP
            PHINOA_1(i) = PHINOA_1_TEMP
            PHINOA_2(i) = PHINOA_2_TEMP
            CSI2(i) = CSI2_TEMP
            CSIO(i) = CSIO_TEMP
            CSOIO(i) = CSOIO_TEMP
            CSI2O2(i) = CSI2O2_TEMP
            CSI2O3(i) = CSI2O3_TEMP
            CSI2O4(i) = CSI2O4_TEMP
            CSI2O5(i) = CSI2O5_TEMP
            CSHOI(i) = CSHOI_TEMP
            CSHI(i) = CSHI_TEMP
            CSINO(i) = CSINO_TEMP
            CSINO2(i) = CSINO2_TEMP
            CSINO3(i) = CSINO3_TEMP
            CSIBr(i) = CSIBr_TEMP
            CSICl(i) = CSICl_TEMP
            CSCH3I(i) = CSCH3I_TEMP
            CSCH2I2(i) = CSCH2I2_TEMP
            CSCH2ICl(i) = CSCH2ICl_TEMP
            CSCH2IBr(i) = CSCH2IBr_TEMP
            CSC2H5I(i) = CSC2H5I_TEMP
            CSnC3H7I(i) = CSnC3H7I_TEMP
            CSiC3H7I(i) = CSiC3H7I_TEMP
            CSBr2(i) = CSBr2_TEMP
            CSBrO(i) = CSBrO_TEMP
            CSHOBr(i) = CSHOBr_TEMP
            CSBrNO2(i) = CSBrNO2_TEMP
            CSBrNO3(i) = CSBrNO3_TEMP
            CSHgBr(i) = CSHgBr_TEMP
            CSHgOH(i) = CSHgOH_TEMP
            CSHgI(i) = CSHgI_TEMP
            CSHgCl(i) = CSHgCl_TEMP
            CSHgCl2(i) = CSHgCl2_TEMP 
            CSHgBr2(i) = CSHgBr2_TEMP
            CSHgBrOOH(i) = CSHgBrOOH_TEMP
			CSHgBrOH(i) = CSHgBrOH_TEMP
            CScisHgBRONO(i) = CScisHgBRONO_TEMP
            CS3SHgO(i) = CS3SHgO_TEMP 
			CS1SHgO(i) = CS1SHgO_TEMP
			CSHgBrNO2(i) = CSHgBrNO2_TEMP
			CSHgBrOI(i) = CSHgBrOI_TEMP
			CSHgBrOBr(i) = CSHgBrOBr_TEMP
			CSHgBrOCl(i) = CSHgBrOCl_TEMP 
			CSHgBrI(i) = CSHgBrI_TEMP 
			CStransHgBrONO(i) = CStransHgBrONO_TEMP
			CSHgOHCl(i) = CSHgOHCl_TEMP 
			CSHgClO(i) = CSHgClO_TEMP
			CSHg(i) = CSHg_TEMP
                              
        END DO
    CLOSE (UNIT=1)
    
    IF (Abs(Latitude) > 70) THEN
        open(UNIT=1, file='inputs/photolysis_files/ColArct.dat')
    ELSEIF (Abs(Latitude) > 20 .AND. Abs(Latitude) <= 70) THEN
        open(UNIT=1, file='inputs/photolysis_files/ColMid.dat')
    ELSEIF (Abs(Latitude) <= 20) THEN
        open(UNIT=1, file='inputs/photolysis_files/ColTrop.dat')
    END IF
    
    DO i = 1, 51
        READ (1, *)  XEDM_TEMP, RAT_TEMP
        XEDM(i) = XEDM_TEMP / 1000000    !convert from m-3 to cm-3
        RAT(i) = RAT_TEMP
    END DO
    CLOSE (UNIT=1)
    
    EDM(1) = XEDM(1)
    DO i = 51, 2, -1
        EDM(i) = (XEDM(i) + XEDM(i - 1)) / 2
    END DO
    
    !EDM(K) is air density (cm**-3)
    !TO3*RAT(K) is the effective ozone col. depth (cm**-2)
    !CRS is Rayleigh scattering cross section (cm**2)
    !CSO3*TO3*RAT(K) is the optical depth of ozone
    !CRS*EDM(K)*dz(cm) is the optical depth of air
    !dz is the layer thickness = 1E5 cm
    !Q_phot(LAM) is the extraterrestrial solar radiation
    
    !! Constants for calculation of the ozone quantum yield
    X1 = 304.225
    X2 = 314.957
    X3 = 310.737
    W1 = 5.576
    W2 = 6.601
    W3 = 2.187
    A1 = 0.8036
    A2 = 8.9061
    A3 = 0.1192
    V1 = 0
    V2 = 825.518
    C1 = 0.0765
    R1 = 0.695
    
    Nwv1 = 516  !Number of wavelength regions
    !! Calculate temperature dependent cross sections and quantum yields
    DO LAM= 1,Nwv1
        !! Calculate O3 quantum yield
        IF (R_WAV(LAM)<306) THEN 
            PHIO3_1(LAM) = 0.9
            PHIO3_2(LAM) = 0.1
        ELSE IF (R_WAV(LAM)>306 .AND. R_WAV(LAM)<328) THEN
            Q1 = EXP(-V1/(R1*TEMP))
            Q2 = EXP(-V2/(R1*TEMP))
            GAUS1 = (Q1/(Q1+Q2))*A1*EXP(-((X1-R_WAV(LAM))/W1)**4)
            GAUS2 = (Q2/(Q1+Q2))*A2*((TEMP/300)**2)*EXP(-((X2-R_WAV(LAM))/W2)**2)
            GAUS3 = A3*((TEMP/300)**1.5)*EXP(-((X3-R_WAV(LAM))/W3)**2)
            PHIO3_1(LAM) = GAUS1 + GAUS2 + GAUS3 + C1
            PHIO3_2(LAM) = 1 - PHIO3_1(LAM)
        ELSE IF (R_WAV(LAM)>328) THEN 
            PHIO3_1(LAM) = 0.08
            PHIO3_2(LAM) = 0.92
        END IF
        !!CROSS-SECTIONS
        CSO3(LAM) = CSO3_A(LAM)*EXP(CSO3_B(LAM)/TEMP)
        CSHNO3(LAM) = CSHNO3_A(LAM)*EXP(CSHNO3_B(LAM)*(TEMP-298))
        CSHCHO(LAM) = CSHCHO_298(LAM) + (CSHCHO_C(LAM)*(TEMP-298))
        CSCH3COCH3(LAM) = CSCH3COCH3_298(LAM)*(1+CSCH3COCH3_A(LAM)*TEMP+ &
                        (CSCH3COCH3_B(LAM)*TEMP**2)+(CSCH3COCH3_C(LAM)*TEMP**3)) 
        CSCH3NO3(LAM) = CSCH3NO3_298(LAM)*EXP(CSCH3NO3_B(LAM)*(TEMP-298))
        CSC2H5NO3(LAM) = CSC2H5NO3_298(LAM)*EXP(CSC2H5NO3_B(LAM)*(TEMP-298))
        CSIC3H7NO3(LAM) = CSIC3H7NO3_298(LAM)*EXP(CSIC3H7NO3_B(LAM)*(TEMP-298))
    END DO
    !Calculate Rayleigh Scattering Perameters
     !Optical Depths
    DO LAM= 1,Nwv1         !DO each wavelength region
        WN(LAM) = 3.916 + 0.074 * (R_wav(LAM) * 0.001) + 0.05 / (R_wav(LAM) * 0.001)
        CRS(LAM) = 4E-28 / ((R_wav(LAM) * 0.001)**WN(LAM))
    END DO
    DO LAM = 1,Nwv1
        T4(1, LAM) = CSO3(LAM) *TO3 * RAT(1) !O3 optical depth
        T1(1, LAM) = CRS(LAM) * EDM(1) * 100000   !air optical depth
        Z1(1, LAM) = Q_phot(LAM) * Exp(-(T4(1, LAM) + T1(1, LAM)) * AMDIR(1))
        DO w = 2,NP
            T4(w, LAM) = CSO3(LAM) *TO3 * RAT(w)
            T1(w, LAM) = CRS(LAM) * EDM(w) * 100000
        END DO    
    END DO
    !TWOSTREAM returns QRAD(K, LAM)
    Call TWOSTREAM(Nwv1, T1, T4, Z1, TAER, AMDIR, AMDIFF, ALBFCT, ALBL, NP, ICLD, ICDSW, CALB, COST, QRAD)
    DO LAM = 1, Nwv1
        !INORGANICS
        J(1) = J(1) + QRAD(IHT, LAM) * CSO3(LAM) * PHIO3_1(LAM)
        J(2) = J(2) + QRAD(IHT, LAM) * CSO3(LAM) * PHIO3_2(LAM)
        J(3) = J(3) + QRAD(IHT, LAM) * CSH2O2(LAM) * PHIH2O2(LAM)
        J(4) = J(4) + QRAD(IHT, LAM) * CSNO2(LAM) * PHINO2(LAM)
        J(5) = J(5) + QRAD(IHT, LAM) * CSNO3(LAM) * PHINO3_1(LAM)
        J(6) = J(6) + QRAD(IHT, LAM) * CSNO3(LAM) * PHINO3_2(LAM)
        J(7) = J(7) + QRAD(IHT, LAM) * CSHONO(LAM)
        J(8) = J(8) + QRAD(IHT, LAM) * CSHNO3(LAM)
        !CARBONYLS
        J(11) = J(11) + QRAD(IHT, LAM) * CSHCHO(LAM) * PHIHCHO_1(LAM)
        J(12) = J(12) + QRAD(IHT, LAM) * CSHCHO(LAM) * PHIHCHO_2(LAM)
        J(13) = J(13) + QRAD(IHT, LAM) * CSCH3CHO(LAM) * PHICH3CHO_2(LAM)
        J(14) = J(14) + QRAD(IHT, LAM) * CSC2H5CHO(LAM) * PHIC2H5CHO(LAM)
        J(15) = J(15) + QRAD(IHT, LAM) * CSC3H7CHO(LAM) * PHIC3H7CHO_1(LAM)
        J(16) = J(16) + QRAD(IHT, LAM) * CSC3H7CHO(LAM) * PHIC3H7CHO_2(LAM)
        J(17) = J(17) + QRAD(IHT, LAM) * CSIPRCHO(LAM) * PHIIPRCHO(LAM)
        J(18) = J(18) + QRAD(IHT, LAM) * CSMACR(LAM) * PHIMACR_1(LAM)
        J(19) = J(19) + QRAD(IHT, LAM) * CSMACR(LAM) * PHIMACR_2(LAM)
        J(21) = J(21) + QRAD(IHT, LAM) * CSCH3COCH3(LAM) * PHICH3COCH3_2(LAM)
        J(22) = J(22) + QRAD(IHT, LAM) * CSMEK(LAM) * PHIMEK(LAM)
        J(23) = J(23) + QRAD(IHT, LAM) * CSMVK(LAM) * PHIMVK_1(LAM)
        J(24) = J(24) + QRAD(IHT, LAM) * CSMVK(LAM) * PHIMVK_2(LAM)
        J(31) = J(31) + QRAD(IHT, LAM) * CSGLYOX(LAM) * PHIGLYOX_1(LAM)
        J(32) = J(32) + QRAD(IHT, LAM) * CSGLYOX(LAM) * PHIGLYOX_2(LAM)
        J(33) = J(33) + QRAD(IHT, LAM) * CSGLYOX(LAM) * PHIGLYOX_3(LAM)
        J(34) = J(34) + QRAD(IHT, LAM) * CSMYGLYOX(LAM) * PHIMYGLYOX(LAM)
        J(35) = J(35) + QRAD(IHT, LAM) * CSBIACET(LAM) * PHIBIACET_1(LAM)
        !ORGANIC PEROXIDES
        J(41) = J(41) + QRAD(IHT, LAM) * CSCH3OOH(LAM)
        !ORGANIC NITRATES
        J(51) = J(51) + QRAD(IHT, LAM) * CSCH3NO3(LAM)
        J(52) = J(52) + QRAD(IHT, LAM) * CSC2H5NO3(LAM)
        J(53) = J(53) + QRAD(IHT, LAM) * CSNC3H7NO3(LAM)
        J(54) = J(54) + QRAD(IHT, LAM) * CSIC3H7NO3(LAM)
        J(55) = J(55) + QRAD(IHT, LAM) * CSTC4H9NO3(LAM)
        J(56) = J(56) + QRAD(IHT, LAM) * CSNOA(LAM) * PHINOA_1(LAM)
        J(57) = J(57) + QRAD(IHT, LAM) * CSNOA(LAM) * PHINOA_1(LAM)
        !!IODINE COMPOUNDS
        J(61) = J(61) + QRAD(IHT, LAM) * CSI2(LAM)
        J(62) = J(62) + QRAD(IHT, LAM) * CSIO(LAM)
        J(63) = J(63) + QRAD(IHT, LAM) * CSOIO(LAM)
        J(64) = J(64) + QRAD(IHT, LAM) * CSI2O2(LAM)
        J(65) = J(65) + QRAD(IHT, LAM) * CSI2O3(LAM)
        J(66) = J(66) + QRAD(IHT, LAM) * CSI2O4(LAM)
        J(67) = J(67) + QRAD(IHT, LAM) * CSI2O5(LAM)
        J(68) = J(68) + QRAD(IHT, LAM) * CSHOI(LAM)
        J(69) = J(69) + QRAD(IHT, LAM) * CSHI(LAM)
        J(70) = J(70) + QRAD(IHT, LAM) * CSINO(LAM)
        J(71) = J(71) + QRAD(IHT, LAM) * CSINO2(LAM)
        J(72) = J(72) + QRAD(IHT, LAM) * CSINO3(LAM)
        J(73) = J(73) + QRAD(IHT, LAM) * CSIBr(LAM)
        J(74) = J(74) + QRAD(IHT, LAM) * CSICl(LAM)
        J(75) = J(75) + QRAD(IHT, LAM) * CSCH3I(LAM)
        J(76) = J(76) + QRAD(IHT, LAM) * CSCH2I2(LAM)
        J(77) = J(77) + QRAD(IHT, LAM) * CSCH2ICl(LAM)
        J(78) = J(78) + QRAD(IHT, LAM) * CSCH2IBr(LAM)
        J(79) = J(79) + QRAD(IHT, LAM) * CSC2H5I(LAM)
        J(80) = J(80) + QRAD(IHT, LAM) * CSnC3H7I(LAM)
        J(81) = J(81) + QRAD(IHT, LAM) * CSiC3H7I(LAM)
        !!BROMINE COMPOUNDS
        J(82) = J(82) + QRAD(IHT, LAM) * CSBr2(LAM)
        J(83) = J(83) + QRAD(IHT, LAM) * CSBrO(LAM)
        J(84) = J(84) + QRAD(IHT, LAM) * CSBrNO3(LAM)
        J(85) = J(85) + QRAD(IHT, LAM) * CSBrNO2(LAM)
        J(86) = J(86) + QRAD(IHT, LAM) * CSHOBr(LAM)
        !!MERCURY COMPOUNDS
        J(90) = J(90) + QRAD(IHT, LAM) * CSHgBr(LAM)
        J(91) = J(91) + QRAD(IHT, LAM) * CSHgOH(LAM)
        J(92) = J(92) + QRAD(IHT, LAM) * CSHgI(LAM)
        J(93) = J(93) + QRAD(IHT, LAM) * CSHgCl(LAM)
        J(94) = J(94) + QRAD(IHT, LAM) * CSHgCl2(LAM)
        J(95) = J(95) + QRAD(IHT, LAM) * CSHgBr2(LAM)
        J(96) = J(96) + QRAD(IHT, LAM) * CSHgBrOOH(LAM)
        J(97) = J(97) + QRAD(IHT, LAM) * CSHgBrOH(LAM)
        J(98) = J(98) + QRAD(IHT, LAM) * CScisHgBRONO(LAM)
        J(99) = J(99) + QRAD(IHT, LAM) * CS3SHgO(LAM)
        J(100) = J(100) + QRAD(IHT, LAM) * CS1SHgO(LAM)
        J(101) = J(101) + QRAD(IHT, LAM) * CSHgBrNO2(LAM)
        J(102) = J(102) + QRAD(IHT, LAM) * CSHgBrOI(LAM)
        J(103) = J(103) + QRAD(IHT, LAM) * CSHgBrOBr(LAM)
        J(104) = J(104) + QRAD(IHT, LAM) * CSHgBrOCl(LAM)
        J(105) = J(105) + QRAD(IHT, LAM) * CSHgBrI(LAM)
        J(106) = J(106) + QRAD(IHT, LAM) * CStransHgBrONO(LAM)
        J(107) = J(107) + QRAD(IHT, LAM) * CSHgOHCl(LAM)
        J(108) = J(108) + QRAD(IHT, LAM) * CSHgClO(LAM)
        J(109) = J(109) + QRAD(IHT, LAM) * CSHg(LAM)
        
        
    END DO
    IF (THETA > 1 * pi / 2 .OR. THETA < -1 * pi / 2) THEN
		DO i = 1, 120
			J(i) = (1.05 * pi / 2 - Abs(THETA)) / ((1.05 - 1) * pi / 2) * J(i)
		END DO
    END IF
    
    DO i = 1, 120
        IF (J(i) < 0) THEN 
            J(i) = 0
        END IF
    END DO
      
END SUBROUTINE PHOTOLYSIS_RATES

SUBROUTINE TWOSTREAM(Nwv1, T1, T4, Z1, TAER, AMDIR, AMDIFF, ALBFCT, ALBL, NP, ICLD, ICDSW, CALB, COST, QRAD)
  USE KPP_ROOT_Model  
    INTEGER :: w, LAM, NWV1, NP, ICDSW, ICLD, ICLD1, ICLD2, ICLDM, ICT, IRAY
    REAL(kind=dp) :: ALBL, COST, ALBFCT, CALB, AMDIFF, TAER
    REAL(kind=dp) :: T1(51,516), T4(51,516), Z1(51,516), QRAD(51,516)
    REAL(kind=dp) :: T3(51,516), Z2(51,516), Z3(51,516), Z4(51,516), Z5(51,516)
    REAL(kind=dp) :: Z7(51,516),Z8(51,516), ZRAD(51,516), AMDIR(51)
    
    !Calculate radiation using two stream method
    !ModIFied from Thompson (1984)
    
    !Insert aerosol optical depth (tropospheric only)
    !and add, Rayleigh scattering term (T1)
    
    DO LAM = 1, Nwv1
        DO w = 41, NP
            T1(w, LAM) = T1(w, LAM) + (TAER * Exp(-0.5 * (NP - w)))
        END DO
    END DO
    DO LAM = 1, Nwv1
        DO w = 2, NP
           T3(w, LAM) = T4(w, LAM) + T1(w, LAM)
           Z3(w, LAM) = Exp(-T3(w, LAM) * AMDIFF)
           Z4(w, LAM) = 0.5 * (Exp(-T4(w, LAM) * AMDIFF) - Z3(w, LAM))
            IF (w <= ICLD) THEN
                Z7(w, LAM) = Exp(-T3(w, LAM) * AMDIR(w))
                Z8(w, LAM) = Exp(-T4(w, LAM) * AMDIR(w)) - Z7(w, LAM)
            ELSE
                Z7(w, LAM) = Z3(w, LAM)
                Z8(w, LAM) = 2 * Z4(w, LAM)
            END IF
        END DO
    END DO
    DO LAM = 1, Nwv1
        DO w = 2, ICLD
           Z1(w, LAM) = Z1(w - 1, LAM) * Z7(w, LAM)
        END DO
    END DO
    DO LAM = 1, Nwv1
        DO w = 1, ICLD
           QRAD(w, LAM) = Z1(w, LAM)
           ZRAD(w, LAM) = Z1(w, LAM)
        END DO
    END DO
    DO LAM = 1, Nwv1
           Z2(ICLD, LAM) = ALBFCT * Z1(ICLD, LAM)
    END DO
    DO LAM = 1, Nwv1
        DO w = ICLD,2,-1
           Z2(w - 1, LAM) = Z2(w, LAM) * Z3(w, LAM)
        END DO
    END DO
    DO LAM = 1, Nwv1
        DO w = 1, ICLD
           QRAD(w, LAM) = QRAD(w, LAM) + Z2(w, LAM)
        END DO
    END DO
    DO LAM = 1, Nwv1
        DO w = 2, ICLD
           Z5(w, LAM) = Z4(w, LAM) * Z2(w, LAM) + COST * Z8(w, LAM) * Z1(w - 1, LAM)
        END DO
    END DO
    DO IRAY = 2, 8
        DO LAM = 1, Nwv1
            IF (IRAY == 2) THEN
                Z1(1, LAM) = Z1(1, LAM) * Z8(2, LAM) * COST
            ELSE
                Z1(1, LAM) = 0
            END IF
        END DO
        DO LAM = 1, Nwv1
            DO w = 2, ICLD
                Z1(w, LAM) = Z1(w - 1, LAM) * Z3(w, LAM) + Z5(w, LAM)
            END DO
        END DO
        DO LAM = 1, Nwv1
            DO w = 1, ICLD
                QRAD(w, LAM) = QRAD(w, LAM) + Z1(w, LAM)
            END DO
        END DO
        DO LAM = 1, Nwv1
            Z2(ICLD, LAM) = ALBL * Z1(ICLD, LAM)
        END DO
        DO LAM = 1, Nwv1
            DO w = ICLD, 2,-1
                Z2(w - 1, LAM) = Z2(w, LAM) * Z3(w, LAM) + Z5(w, LAM)
            END DO
        END DO
        DO LAM = 1, Nwv1
            DO w = 1, ICLD
                QRAD(w, LAM) = QRAD(w, LAM) + Z2(w, LAM)
            END DO
        END DO
        IF (IRAY < 8) THEN
            DO LAM = 1, Nwv1
                DO w = 2, ICLD
                    Z5(w, LAM) = Z4(w, LAM) * (Z2(w, LAM) + Z1(w - 1, LAM))
                END DO
            END DO
        END IF
    END DO
    !CALCULATE RADIATION FIELD BELOW CLOUD
    IF (ICDSW > 0 .OR. ICDSW < 0) THEN
        ICLD1 = ICLD + 1
        ICLD2 = ICLD + 2
        ICLDM = ICLD - 1
        ICT = NP - ICLD1
        !OVERWRITE GROUND ALBEDO TO 0.1 BELOW CLOUD
        ALBL = 0.1
        ALBFCT = 2 * ALBL * COST
        DO LAM = 1, Nwv1
            Z1(ICLD1, LAM) = (1 - CALB) * Z3(ICLD1, LAM) * QRAD(ICLD, LAM)
        END DO
        DO LAM = 1, Nwv1
            DO w = ICLD2, NP
                Z1(w, LAM) = Z1(w - 1, LAM) * Z3(w, LAM)
            END DO
        END DO
        DO LAM = 1, Nwv1
            DO w = ICLD1, NP
                QRAD(w, LAM) = Z1(w, LAM)
                ZRAD(w, LAM) = Z1(w, LAM)
            END DO
        END DO
        DO LAM = 1, Nwv1
            Z2(NP, LAM) = ALBL * Z1(NP, LAM)
        END DO
        DO LAM = 1, Nwv1
            DO w = NP, ICLD2, -1
                Z2(w - 1, LAM) = Z2(w, LAM) * Z3(w, LAM)
            END DO
        END DO
        DO LAM = 1, Nwv1
            DO w = ICLD1, NP
                QRAD(w, LAM) = QRAD(w, LAM) + Z2(w, LAM)
            END DO
        END DO
        DO LAM = 1, Nwv1
            DO w = ICLD2, NP
                Z5(w, LAM) = Z4(w, LAM) * Z2(w, LAM) + Z4(w, LAM) * Z1(w - 1, LAM)
            END DO
        END DO
        DO IRAY = 2, 8
            DO LAM = 1, Nwv1
                IF (IRAY == 2) THEN
                    Z1(ICLD1, LAM) = CALB * Z2(ICLD1, LAM)
                ELSE
                    Z1(ICLD1, LAM) = 0
                END IF
            END DO
            DO LAM = 1, Nwv1
                DO w = ICLD2, NP
                    Z1(w, LAM) = Z1(w - 1, LAM) * Z3(w, LAM) + Z5(w, LAM)
                END DO
            END DO
            DO LAM = 1, Nwv1
                DO w = ICLD1, NP
                    QRAD(w, LAM) = QRAD(w, LAM) + Z1(w, LAM)
                END DO
            END DO
            DO LAM = 1, Nwv1
                Z2(NP, LAM) = ALBL * Z1(NP, LAM)
            END DO
            DO LAM = 1, Nwv1
                DO w = NP, ICLD2, -1
                    Z2(w - 1, LAM) = Z2(w, LAM) * Z3(w, LAM) + Z5(w, LAM)
                END DO
            END DO
            DO LAM = 1, Nwv1
                DO w = ICLD1, NP
                    QRAD(w, LAM) = QRAD(w, LAM) + Z2(w, LAM)
                END DO
            END DO
            IF (IRAY < 8 .OR. IRAY > 8) THEN
                DO LAM = 1, Nwv1
                    DO w = ICLD2, NP
                        Z5(w, LAM) = Z4(w, LAM) * (Z2(w, LAM) + Z1(w - 1, LAM))
                    END DO
                END DO
            END IF
        END DO
    END IF
END SUBROUTINE

SUBROUTINE CHECK_SZA ()
USE KPP_ROOT_Model
    
    REAL(kind=dp) :: TIMEIS
    REAL(kind=dp) :: C1, C2, C3, C4, C5
    REAL(kind=dp) :: D1, D2, D3, D4, D5, D6, D7
    REAL(kind=dp) :: LatRad, Theta, Delta, Corr
    double precision :: HA, CT
    !Making the SZA an unrealistic value
    SZA = 400
    
    TIMEIS=TIME/3600
    
    C1 = 0.000075
    C2 = 0.001868
    C3 = -0.032077
    C4 = -0.014615
    C5 = -0.040849
    
    D1 = 0.006981
    D2 = -0.399912
    D3 = 0.070257
    D4 = -0.006758
    D5 = 0.000907
    D6 = -0.002697
    D7 = 0.00148
    
    LatRad = (PI / 180) * Latitude
    Theta = 2 * pi * (JDAY - 1) / 365
    Delta = D1 + D2 * Cos(Theta) + D3 * Sin(Theta) + D4 * Cos(2 * Theta) + D5 * Sin(2 * Theta) &
            + D6 * Cos(3 * Theta) + D7 * Sin(3 * Theta)
    Corr = C1 + C2 * Cos(Theta) + C3 * Sin(Theta) + C4 * Cos(2 * Theta) + C5 * Sin(2 * Theta)
    HA = (TIMEIS - 12) * 15 - 0     !Change 0, Longitude IF necessary
    !HA = (Timeis) * 15 - 0
    HA = pi / 180 * HA
    HA = HA + Corr
    CT = Sin(LatRad) * Sin(Delta) + Cos(LatRad) * Cos(Delta) * Cos(HA)
    !        SZA = SQRT((1 / Sqr(CT)) - 1)
    !        SZA = SQRT((1 / (CT * CT) ** (1 / 4)) - 1)
    SZA = SQRT((1 / (CT * CT)) - 1)
    SZA = ATAN(SZA)
    SZA = 180 / pi * SZA
    
    IF (CT < 0) THEN 
        SZA = 180 - SZA
    END IF

END SUBROUTINE

SUBROUTINE ROPA_RODA ()
USE KPP_ROOT_Model
USE KPP_ROOT_Function
    INTEGER :: SPECIES_NO,RCT_NO,i,startpos
    CHARACTER(len=100) :: reactionsname,reactantspart,productspart,out_str
    CHARACTER :: ch
    INTEGER,PARAMETER::specieslength = 2
    CHARACTER(len=specieslength) :: SPECIES_NAME1
    CHARACTER(len=specieslength+2) :: SPECIES_NAME2
    
    !!!***REMEMBER TO CHANGE THE specieslength ***
    SPECIES_NAME1 = 'O3'
    !!!***REMEMBER TO CHANGE THE specieslength ***
    SPECIES_NAME2 = ' ' // SPECIES_NAME1 // ' '    
    
        IF (TIME < 3601) THEN
            !Open file to output the RODA data
            open(UNIT=7, file='outputs/RODA.csv')
            !Open file to output the ROPA data
            open(UNIT=8, file='outputs/ROPA.csv')
            write(7,'(2(1x,A))',advance="no")'Time'
            write(8,'(2(1x,A))',advance="no")'Time'
            DO SPECIES_NO=1,NVAR
                IF (SPC_NAMES(SPECIES_NO) == SPECIES_NAME1) THEN
                    DO RCT_NO=1,NREACT
                        reactionsname = EQN_NAMES(RCT_NO)
                        startpos = INDEX(reactionsname,'-->')
                        reactantspart=reactionsname(1:startpos-1)
                        productspart=reactionsname(startpos+3:LEN(reactionsname))
                       
                        !!RODA
                        startpos = INDEX(reactantspart,SPECIES_NAME2)
                        IF (startpos>0) THEN
                            out_str = " "
                            DO i=1, len_trim(EQN_NAMES(RCT_NO))
                                ! get i-th char
                                ch = EQN_NAMES(RCT_NO)(i:i)
                                IF (ch .ne. " ") THEN
                                    out_str = trim(out_str) // ch
                                END IF
                            END DO
                            write(7,'(2(1x,A))',advance="no") trim(out_str), ' '
                        END IF
                        
                        !!ROPA
                        startpos = INDEX(productspart,SPECIES_NAME2)
                        IF (startpos>0) THEN
                            out_str = " "
                            DO i=1, len_trim(EQN_NAMES(RCT_NO))
                                ! get i-th char
                                ch = EQN_NAMES(RCT_NO)(i:i)
                                IF (ch .ne. " ") THEN
                                    out_str = trim(out_str) // ch
                                END IF
                            END DO
                            write(8,'(2(1x,A))',advance="no") trim(out_str), ' '
                        END IF  
                    END DO
                END IF
            END DO
            write(7,*) ''
            write(8,*) '' 
        END IF
        write(7,'(E24.16)',advance="no")(TIME-TSTART)/3600.D0
        write(8,'(E24.16)',advance="no")(TIME-TSTART)/3600.D0
        DO SPECIES_NO=1,NVAR
            IF (SPC_NAMES(SPECIES_NO) == SPECIES_NAME1) THEN
                DO RCT_NO=1,NREACT
                    reactionsname = EQN_NAMES(RCT_NO)
                    startpos = INDEX(reactionsname,'-->')
                    reactantspart=reactionsname(1:startpos-1)
                    productspart=reactionsname(startpos+3:LEN(reactionsname))
                   
                    !!RODA
                    startpos = INDEX(reactantspart,SPECIES_NAME2)
                    IF (startpos>0) THEN
                        write(7,'(E24.16)',advance="no") -A(RCT_NO)
                    END IF
                    
                    !!ROPA
                    startpos = INDEX(productspart,SPECIES_NAME2)
                    IF (startpos>0) THEN
                        write(8,'(E24.16)',advance="no") A(RCT_NO)
                    END IF  
                END DO
            END IF
        END DO
        write(7,*) ''
        write(8,*) ''

END SUBROUTINE


SUBROUTINE MAKE_PLOTS ()
		
	!!Plot the chemistry
	call system("python inputs/plot_codes/BoxPlots.py")
	call system("cmd.exe /C start outputs/chemistry.pdf &")
	
	!!Plot the photolysis rates
	call system("python inputs/plot_codes/ModelPhotolysisPlot.py")
	call system("cmd.exe /C start outputs/photolysis.pdf &")

END SUBROUTINE

