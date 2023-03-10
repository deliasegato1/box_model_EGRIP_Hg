! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! Parameter Module File
! 
! Generated by KPP-2.2.3 symbolic chemistry Kinetics PreProcessor
!       (http://www.cs.vt.edu/~asandu/Software/KPP)
! KPP is distributed under GPL, the general public licence
!       (http://www.gnu.org/copyleft/gpl.html)
! (C) 1995-1997, V. Damian & A. Sandu, CGRER, Univ. Iowa
! (C) 1997-2005, A. Sandu, Michigan Tech, Virginia Tech
!     With important contributions from:
!        M. Damian, Villanova University, USA
!        R. Sander, Max-Planck Institute for Chemistry, Mainz, Germany
! 
! File                 : box_Parameters.f90
! Time                 : Thu Oct 21 15:31:35 2021
! Working directory    : /mnt/d/OneDrive/modelling/kpp/box_mercury_updated
! Equation file        : box.kpp
! Output root filename : box
! 
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



MODULE box_Parameters

  USE box_Precision
  PUBLIC
  SAVE


! NSPEC - Number of chemical species
  INTEGER, PARAMETER :: NSPEC = 112 
! NVAR - Number of Variable species
  INTEGER, PARAMETER :: NVAR = 107 
! NVARACT - Number of Active species
  INTEGER, PARAMETER :: NVARACT = 95 
! NFIX - Number of Fixed species
  INTEGER, PARAMETER :: NFIX = 5 
! NREACT - Number of reactions
  INTEGER, PARAMETER :: NREACT = 316 
! NVARST - Starting of variables in conc. vect.
  INTEGER, PARAMETER :: NVARST = 1 
! NFIXST - Starting of fixed in conc. vect.
  INTEGER, PARAMETER :: NFIXST = 108 
! NONZERO - Number of nonzero entries in Jacobian
  INTEGER, PARAMETER :: NONZERO = 604 
! LU_NONZERO - Number of nonzero entries in LU factoriz. of Jacobian
  INTEGER, PARAMETER :: LU_NONZERO = 669 
! CNVAR - (NVAR+1) Number of elements in compressed row format
  INTEGER, PARAMETER :: CNVAR = 108 
! NLOOKAT - Number of species to look at
  INTEGER, PARAMETER :: NLOOKAT = 49 
! NMONITOR - Number of species to monitor
  INTEGER, PARAMETER :: NMONITOR = 5 
! NMASS - Number of atoms to check mass balance
  INTEGER, PARAMETER :: NMASS = 1 

! Index declaration for variable species in C and VAR
!   VAR(ind_spc) = C(ind_spc)

  INTEGER, PARAMETER :: ind_I2_flux = 1 
  INTEGER, PARAMETER :: ind_I2O5 = 2 
  INTEGER, PARAMETER :: ind_CH3I = 3 
  INTEGER, PARAMETER :: ind_C2H5I = 4 
  INTEGER, PARAMETER :: ind_CH2I2 = 5 
  INTEGER, PARAMETER :: ind_CH2IBr = 6 
  INTEGER, PARAMETER :: ind_CH2ICl = 7 
  INTEGER, PARAMETER :: ind_nC3H7I = 8 
  INTEGER, PARAMETER :: ind_iC3H7I = 9 
  INTEGER, PARAMETER :: ind_IBr = 10 
  INTEGER, PARAMETER :: ind_O1D = 11 
  INTEGER, PARAMETER :: ind_HOCl = 12 
  INTEGER, PARAMETER :: ind_OClO = 13 
  INTEGER, PARAMETER :: ind_Hg_DryDep = 14 
  INTEGER, PARAMETER :: ind_Hg_WetDep = 15 
  INTEGER, PARAMETER :: ind_Hg_AerDep = 16 
  INTEGER, PARAMETER :: ind_CO2 = 17 
  INTEGER, PARAMETER :: ind_H = 18 
  INTEGER, PARAMETER :: ind_NA = 19 
  INTEGER, PARAMETER :: ind_SA = 20 
  INTEGER, PARAMETER :: ind_SO3 = 21 
  INTEGER, PARAMETER :: ind_CH3CO = 22 
  INTEGER, PARAMETER :: ind_DUMMY = 23 
  INTEGER, PARAMETER :: ind_DMSO = 24 
  INTEGER, PARAMETER :: ind_HgBr_aq = 25 
  INTEGER, PARAMETER :: ind_HgBr2_aq = 26 
  INTEGER, PARAMETER :: ind_HgBrOH_aq = 27 
  INTEGER, PARAMETER :: ind_HgBrCl_aq = 28 
  INTEGER, PARAMETER :: ind_HgBrNO2_aq = 29 
  INTEGER, PARAMETER :: ind_HgBrHO2_aq = 30 
  INTEGER, PARAMETER :: ind_HgBrO_aq = 31 
  INTEGER, PARAMETER :: ind_HgOH_aq = 32 
  INTEGER, PARAMETER :: ind_HgOHOH_aq = 33 
  INTEGER, PARAMETER :: ind_HgOHCl_aq = 34 
  INTEGER, PARAMETER :: ind_HgOHNO2_aq = 35 
  INTEGER, PARAMETER :: ind_HgOHNO2 = 36 
  INTEGER, PARAMETER :: ind_HgOHHO2_aq = 37 
  INTEGER, PARAMETER :: ind_HgOHO_aq = 38 
  INTEGER, PARAMETER :: ind_HgCl_aq = 39 
  INTEGER, PARAMETER :: ind_HgCl2_aq = 40 
  INTEGER, PARAMETER :: ind_HgClNO2_aq = 41 
  INTEGER, PARAMETER :: ind_HgClHO2_aq = 42 
  INTEGER, PARAMETER :: ind_HgClO_aq = 43 
  INTEGER, PARAMETER :: ind_N2O5 = 44 
  INTEGER, PARAMETER :: ind_CH3O2NO2 = 45 
  INTEGER, PARAMETER :: ind_HgO = 46 
  INTEGER, PARAMETER :: ind_HSO3 = 47 
  INTEGER, PARAMETER :: ind_CH3CHO = 48 
  INTEGER, PARAMETER :: ind_I2O4 = 49 
  INTEGER, PARAMETER :: ind_HgOHO = 50 
  INTEGER, PARAMETER :: ind_HgClNO2 = 51 
  INTEGER, PARAMETER :: ind_HgBrNO2 = 52 
  INTEGER, PARAMETER :: ind_BrCl = 53 
  INTEGER, PARAMETER :: ind_HgOHHO2 = 54 
  INTEGER, PARAMETER :: ind_ICl = 55 
  INTEGER, PARAMETER :: ind_ClO = 56 
  INTEGER, PARAMETER :: ind_HgCl2 = 57 
  INTEGER, PARAMETER :: ind_HgOHOH = 58 
  INTEGER, PARAMETER :: ind_H2 = 59 
  INTEGER, PARAMETER :: ind_H2O2 = 60 
  INTEGER, PARAMETER :: ind_BrNO2 = 61 
  INTEGER, PARAMETER :: ind_HONO = 62 
  INTEGER, PARAMETER :: ind_HO2NO2 = 63 
  INTEGER, PARAMETER :: ind_HgBr2 = 64 
  INTEGER, PARAMETER :: ind_I2O2 = 65 
  INTEGER, PARAMETER :: ind_I2O3 = 66 
  INTEGER, PARAMETER :: ind_BrNO = 67 
  INTEGER, PARAMETER :: ind_INO2 = 68 
  INTEGER, PARAMETER :: ind_HgBrO = 69 
  INTEGER, PARAMETER :: ind_HgClO = 70 
  INTEGER, PARAMETER :: ind_SO2 = 71 
  INTEGER, PARAMETER :: ind_INO = 72 
  INTEGER, PARAMETER :: ind_CH3OH = 73 
  INTEGER, PARAMETER :: ind_HNO3 = 74 
  INTEGER, PARAMETER :: ind_DMS = 75 
  INTEGER, PARAMETER :: ind_HgClHO2 = 76 
  INTEGER, PARAMETER :: ind_HgBrHO2 = 77 
  INTEGER, PARAMETER :: ind_CH3NO3 = 78 
  INTEGER, PARAMETER :: ind_CH3O = 79 
  INTEGER, PARAMETER :: ind_HgBrCl = 80 
  INTEGER, PARAMETER :: ind_CH3OOH = 81 
  INTEGER, PARAMETER :: ind_HBr = 82 
  INTEGER, PARAMETER :: ind_BrONO2 = 83 
  INTEGER, PARAMETER :: ind_HI = 84 
  INTEGER, PARAMETER :: ind_IONO2 = 85 
  INTEGER, PARAMETER :: ind_HgOHCl = 86 
  INTEGER, PARAMETER :: ind_HOI = 87 
  INTEGER, PARAMETER :: ind_HgBrOH = 88 
  INTEGER, PARAMETER :: ind_Br2 = 89 
  INTEGER, PARAMETER :: ind_OIO = 90 
  INTEGER, PARAMETER :: ind_HCHO = 91 
  INTEGER, PARAMETER :: ind_HOBr = 92 
  INTEGER, PARAMETER :: ind_Cl = 93 
  INTEGER, PARAMETER :: ind_HgOH = 94 
  INTEGER, PARAMETER :: ind_HgCl = 95 
  INTEGER, PARAMETER :: ind_HgBr = 96 
  INTEGER, PARAMETER :: ind_CH3O2 = 97 
  INTEGER, PARAMETER :: ind_I2 = 98 
  INTEGER, PARAMETER :: ind_I = 99 
  INTEGER, PARAMETER :: ind_OH = 100 
  INTEGER, PARAMETER :: ind_NO = 101 
  INTEGER, PARAMETER :: ind_NO3 = 102 
  INTEGER, PARAMETER :: ind_IO = 103 
  INTEGER, PARAMETER :: ind_Br = 104 
  INTEGER, PARAMETER :: ind_HO2 = 105 
  INTEGER, PARAMETER :: ind_O = 106 
  INTEGER, PARAMETER :: ind_BrO = 107 

! Index declaration for fixed species in C
!   C(ind_spc)

  INTEGER, PARAMETER :: ind_Hg = 108 
  INTEGER, PARAMETER :: ind_O3 = 109 
  INTEGER, PARAMETER :: ind_NO2 = 110 
  INTEGER, PARAMETER :: ind_CO = 111 
  INTEGER, PARAMETER :: ind_CH4 = 112 

! Index declaration for fixed species in FIX
!    FIX(indf_spc) = C(ind_spc) = C(NVAR+indf_spc)

  INTEGER, PARAMETER :: indf_Hg = 1 
  INTEGER, PARAMETER :: indf_O3 = 2 
  INTEGER, PARAMETER :: indf_NO2 = 3 
  INTEGER, PARAMETER :: indf_CO = 4 
  INTEGER, PARAMETER :: indf_CH4 = 5 

END MODULE box_Parameters

