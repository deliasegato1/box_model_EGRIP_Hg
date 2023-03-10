! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! Global Data Module File
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
! File                 : box_Global.f90
! Time                 : Thu Oct 21 15:31:35 2021
! Working directory    : /mnt/d/OneDrive/modelling/kpp/box_mercury_updated
! Equation file        : box.kpp
! Output root filename : box
! 
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



MODULE box_Global

  USE box_Parameters, ONLY: dp, NSPEC, NVAR, NFIX, NREACT
  PUBLIC
  SAVE


! Declaration of global variables

! C - Concentration of all species
  REAL(kind=dp) :: C(NSPEC)
! VAR - Concentrations of variable species (global)
  REAL(kind=dp) :: VAR(NVAR)
! FIX - Concentrations of fixed species (global)
  REAL(kind=dp) :: FIX(NFIX)
! VAR, FIX are chunks of array C
      EQUIVALENCE( C(1),VAR(1) )
      EQUIVALENCE( C(108),FIX(1) )
! RCONST - Rate constants (global)
  REAL(kind=dp) :: RCONST(NREACT)
! TIME - Current integration time
  REAL(kind=dp) :: TIME
! SUN - Sunlight intensity between [0,1]
  REAL(kind=dp) :: SUN
! TEMP - Temperature
  REAL(kind=dp) :: TEMP
! RTOLS - (scalar) Relative tolerance
  REAL(kind=dp) :: RTOLS
! TSTART - Integration start time
  REAL(kind=dp) :: TSTART
! TEND - Integration end time
  REAL(kind=dp) :: TEND
! DT - Integration step
  REAL(kind=dp) :: DT
! ATOL - Absolute tolerance
  REAL(kind=dp) :: ATOL(NVAR)
! RTOL - Relative tolerance
  REAL(kind=dp) :: RTOL(NVAR)
! STEPMIN - Lower bound for integration step
  REAL(kind=dp) :: STEPMIN
! STEPMAX - Upper bound for integration step
  REAL(kind=dp) :: STEPMAX
! CFACTOR - Conversion factor for concentration units
  REAL(kind=dp) :: CFACTOR

! INLINED global variable declarations

  REAL(kind=dp) :: PRESSURE                 ! Pressure
  REAL(kind=dp) :: H_alt, windspeed         ! BL height and wind speed at 10 m
  REAL(kind=dp) :: ASA, AVOL, aerosol_loss ! Aerosol surface area, volume, loss 
  REAL(kind=dp) :: J(120), jfactor, jfactor2, factortime  ! Species mass array
  REAL(kind=dp) :: J1_MAX
  !! The jfactor is defined according to the O3 cross-section
  !! Change in the main program in the driver file
  !!Constants
  REAL(kind=dp) :: AVOG = 6.023E+23         !Avogadro's constant
  REAL(kind=dp) :: PI = 3.14                !PI
  INTEGER :: JDAY                           !Julian Day
  REAL(kind=dp) :: LATITUDE, SZA, RelHum, Cair  !Latitude AND solar zenith angle
  INTEGER, PARAMETER :: num_bins=30 !Number of bins for coagulation routine
  !!Boltzmann constant(kg m^2 s^-2 K^-1 molec^-1)
  REAL(kind=dp) :: k_boltz = 1.3807D-23, v_rat
  
! INLINED global variable declarations


END MODULE box_Global

