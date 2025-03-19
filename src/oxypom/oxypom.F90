!! SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
!! SPDX-License-Identifier: Apache-2.0
!! SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

!! FABM implementation for biogeochemical model described in:
!! Holzwarth and Wirtz (2018) https://doi.org/10.1016/j.ecss.2018.01.020


#include "fabm_driver.h"

module oxypom_oxypom
    use fabm_types
    implicit none
    private

    type, extends(type_base_model), public :: type_oxypom_oxypom
        ! External dependencies
        type (type_dependency_id) :: id_temp
        type (type_dependency_id) :: id_par
        type (type_bottom_dependency_id) :: id_depth
        type (type_dependency_id) :: id_salinity
        type (type_surface_dependency_id) :: id_wind
        type (type_surface_dependency_id) :: id_I0
		type (type_diagnostic_variable_id) :: id_dPAR

        ! Variable identifiers
		type (type_state_variable_id) :: id_ALG1
		type (type_state_variable_id) :: id_ALG2
		type (type_state_variable_id) :: id_POC1
		type (type_state_variable_id) :: id_POC2
		type (type_state_variable_id) :: id_DOC
		type (type_state_variable_id) :: id_NH4
		type (type_state_variable_id) :: id_NO3
		type (type_state_variable_id) :: id_PON1
		type (type_state_variable_id) :: id_PON2
		type (type_state_variable_id) :: id_DON
		type (type_state_variable_id) :: id_PO4
		type (type_state_variable_id) :: id_POP1
		type (type_state_variable_id) :: id_POP2
		type (type_state_variable_id) :: id_DOP
		type (type_state_variable_id) :: id_Si
		type (type_state_variable_id) :: id_OPAL
		type (type_state_variable_id) :: id_DOxy

		! Model parameters
		real(rk) :: an
		real(rk) :: ap
		real(rk) :: asi
		real(rk) :: amc
		real(rk) :: ea
		real(rk) :: ep
		real(rk) :: es
		real(rk) :: etb
		real(rk) :: fdec12
		real(rk) :: fdec13
		real(rk) :: fdec23
		real(rk) :: fgr
		real(rk) :: fra
		real(rk) :: Io201
		real(rk) :: Io202
		real(rk) :: kdiss
		real(rk) :: kmin1
		real(rk) :: kmin2
		real(rk) :: kmin3
		real(rk) :: kmr1
		real(rk) :: kmr2
		real(rk) :: kmrt
		real(rk) :: knit
		real(rk) :: kpp
		real(rk) :: Ksam
		real(rk) :: Ksni
		real(rk) :: Ksn
		real(rk) :: Ksox
		real(rk) :: Ksoxi
		real(rk) :: Ksoxc
		real(rk) :: Ksp
		real(rk) :: Kssi
		real(rk) :: sieq
		real(rk) :: SPMI
		real(rk) :: sv
		real(rk) :: svALG
   
    contains
        procedure :: initialize
        procedure :: do
        procedure :: do_surface
    end type

contains

    subroutine initialize(self, configunit)
        class (type_oxypom_oxypom), intent(inout), target :: self
        integer, intent(in) :: configunit
        
        real(rk), parameter :: d_per_s = 1.0_rk/86400.0_rk

        ! Store parameter values in our own derived type
        ! All rates must be provided in values per day and are converted here to values per second.
		call self%get_parameter(self%an, 'an', '--', 'stoichiometric ratio N:C phytoplankton', default=6.625_rk)
		call self%get_parameter(self%ap, 'ap', '--', 'stoichiometric ratio P:C phytoplankton', default=106.0_rk)
		call self%get_parameter(self%asi, 'asi', '--', 'stoichiometric ratio Si:C diatoms', default=7.06666666666667_rk)
		call self%get_parameter(self%amc, 'amc', 'mmol N m-3', 'critical concentration NH4 uptake', default=0.71_rk)
		call self%get_parameter(self%ea, 'ea', 'm2 mmol C-1', 'specific light extinction coeff. Algae', default=0.0012_rk)
		call self%get_parameter(self%ep, 'ep', 'm2 mmol C-1', 'specific light extinction coeff. POC', default=0.0012_rk)
		call self%get_parameter(self%es, 'es', 'm2 g-1', 'spec. light extinction coeff. background', default=0.03_rk)
		call self%get_parameter(self%etb, 'etb', 'm-1', 'partial extinction coeff. Background', default=0.0_rk)
		call self%get_parameter(self%fdec12, 'fdec12', '--', 'factor decomposition POC1 to POC2', default=0.5_rk)
		call self%get_parameter(self%fdec13, 'fdec13', '--', 'factor decomposition POC1 to DOC', default=0.5_rk)
		call self%get_parameter(self%fdec23, 'fdec23', '--', 'factor decomposition POC2 to DOC', default=1.0_rk)
		call self%get_parameter(self%fgr, 'fgr', '--', 'growht respiration factor algae', default=0.065_rk)
		call self%get_parameter(self%fra, 'fra', '--', 'fraction released by autolysis', default=0.5_rk)
		call self%get_parameter(self%Io201, 'Io201', 'W m-2', 'optimal light intensity for ALG1', default=20.0_rk)
		call self%get_parameter(self%Io202, 'Io202', 'W m-2', 'optimal light intensity for ALG2', default=30.0_rk)
		call self%get_parameter(self%kdiss, 'kdiss', 'm3 mmol Si-1 d-1', 'OPAL dissolution reaction rate constant', default=3e-06_rk)
		call self%get_parameter(self%kmin1, 'kmin1', 'd-1', 'mineralization rate constant POC1 at 20deg', default=0.4_rk)
		call self%get_parameter(self%kmin2, 'kmin2', 'd-1', 'mineralization rate constant POC2 at 20deg', default=0.05_rk)
		call self%get_parameter(self%kmin3, 'kmin3', 'd-1', 'mineralization rate constant DOC at 20deg', default=0.15_rk)
		call self%get_parameter(self%kmr1, 'kmr1', 'd-1', 'ALG1 maintenance respiration rate constant at 20deg', default=0.036_rk)
		call self%get_parameter(self%kmr2, 'kmr2', 'd-1', 'ALG2 maintenance respiration rate constant at 20deg', default=0.045_rk)
		call self%get_parameter(self%kmrt, 'kmrt', 'd-1', 'mortality rate constant phytoplankton at 20deg', default=0.5_rk)
		call self%get_parameter(self%knit, 'knit', 'mmol N m-3 d-1', 'nitrification rate constant at 20deg', default=28.6_rk)
		call self%get_parameter(self%kpp, 'kpp', 'd-1', 'potential max. production rate constant ALGi', default=1.2_rk)
		call self%get_parameter(self%Ksam, 'Ksam', 'mmol N m-3', 'half saturation NH4 limitation in nitrification', default=36.0_rk)
		call self%get_parameter(self%Ksni, 'Ksni', 'mmol N m-3', 'half saturation NO3 in denitrification', default=36.0_rk)
		call self%get_parameter(self%Ksn, 'Ksn', 'mmol N m-3', 'half saturation N concentration in nPP', default=0.36_rk)
		call self%get_parameter(self%Ksox, 'Ksox', 'mmol O2 m-3', 'half saturation DO in nitrification', default=31.3_rk)
		call self%get_parameter(self%Ksoxi, 'Ksoxi', 'mmol O2 m-3', 'half saturation DO inhibition in denitrification', default=94.0_rk)
		call self%get_parameter(self%Ksoxc, 'Ksoxc', 'mmol O2 m-3', 'half saturation DO consumption in minerals', default=63.0_rk)
		call self%get_parameter(self%Ksp, 'Ksp', 'mmol P m-3', 'half saturation P in nPP', default=0.03_rk)
		call self%get_parameter(self%Kssi, 'Kssi', 'mmol Si m-3', 'half saturation silicate in nPP', default=1.0_rk)
		call self%get_parameter(self%sieq, 'sieq', 'mmol Si m-3', 'equilibrium concentration Si', default=357.0_rk)
		call self%get_parameter(self%SPMI, 'SPMI', 'g m-3', 'inorganic suspended particular matter concentration', default=47.0_rk)
		call self%get_parameter(self%sv, 'sv', 'm d-1', 'settling velocity POC', default=-0.5_rk)
		call self%get_parameter(self%svALG, 'svALG', 'm d-1', 'settling velocity phytoplankton', default=-0.5_rk)

		! Register state variables
		call self%register_state_variable(self%id_ALG1, 'ALG1', 'mmol C m-3', 'diatom', 1.0_rk, minimum=0.0_rk, maximum=1000.0_rk, vertical_movement=self%svALG*d_per_s)
		call self%register_state_variable(self%id_ALG2, 'ALG2', 'mmol C m-3', 'non-diatom', 0.20_rk, minimum=0.0_rk, maximum=1000.0_rk, vertical_movement=self%svALG*d_per_s)
		call self%register_state_variable(self%id_POC1, 'POC1', 'mmol C m-3', 'POC1 ', 2.0_rk, minimum=0.0_rk, maximum=1000.0_rk, vertical_movement=self%sv*d_per_s)
		call self%register_state_variable(self%id_POC2, 'POC2', 'mmol C m-3', 'POC2 ', 3.0_rk, minimum=0.0_rk, maximum=1000.0_rk, vertical_movement=self%sv*d_per_s)
		call self%register_state_variable(self%id_DOC, 'DOC', 'mmol C m-3', 'DOC', 500.0_rk, minimum=0.0_rk, maximum=1000.0_rk, vertical_movement=0.0_rk*d_per_s)
		call self%register_state_variable(self%id_NH4, 'NH4', 'mmol N m-3', 'ammonia', 2.0_rk, minimum=0.0_rk, maximum=1000.0_rk, vertical_movement=0.0_rk*d_per_s)
		call self%register_state_variable(self%id_NO3, 'NO3', 'mmol N m-3', 'nitrate', 400.0_rk, minimum=0.0_rk, maximum=1000.0_rk, vertical_movement=0.0_rk*d_per_s)
		call self%register_state_variable(self%id_PON1, 'PON1', 'mmol N m-3', 'PON1', 20.0_rk, minimum=0.0_rk, maximum=1000.0_rk, vertical_movement=self%sv*d_per_s)
		call self%register_state_variable(self%id_PON2, 'PON2', 'mmol N m-3', 'PON2 ', 20.0_rk, minimum=0.0_rk, maximum=1000.0_rk, vertical_movement=self%sv*d_per_s)
		call self%register_state_variable(self%id_DON, 'DON', 'mmol N m-3', 'DON', 20.0_rk, minimum=0.0_rk, maximum=1000.0_rk, vertical_movement=0.0_rk*d_per_s)
		call self%register_state_variable(self%id_PO4, 'PO4', 'mmol P m-3', 'phosphate', 1.0_rk, minimum=0.0_rk, maximum=50.0_rk, vertical_movement=0.0_rk*d_per_s)
		call self%register_state_variable(self%id_POP1, 'POP1', 'mmol P m-3', 'POP1 ', 0.5_rk, minimum=0.0_rk, maximum=50.0_rk, vertical_movement=self%sv*d_per_s)
		call self%register_state_variable(self%id_POP2, 'POP2', 'mmol P m-3', 'POP2 ', 0.5_rk, minimum=0.0_rk, maximum=50.0_rk, vertical_movement=self%sv*d_per_s)
		call self%register_state_variable(self%id_DOP, 'DOP', 'mmol P m-3', 'DOP', 0.5_rk, minimum=0.0_rk, maximum=50.0_rk, vertical_movement=0.0_rk*d_per_s)
		call self%register_state_variable(self%id_Si, 'Si', 'mmol Si m-3', 'Silicate', 200.0_rk, minimum=0.0_rk, maximum=1000.0_rk, vertical_movement=0.0_rk*d_per_s)
		call self%register_state_variable(self%id_OPAL, 'OPAL', 'mmol Si m-3', 'opal', 10.0_rk, minimum=0.0_rk, maximum=2000.0_rk, vertical_movement=self%sv*d_per_s)
		call self%register_state_variable(self%id_DOxy, 'DOxy', 'mmol O2 m-3', 'dissolved oxygen', 300.0_rk, minimum=0.0_rk, maximum=600.0_rk, vertical_movement=0.0_rk*d_per_s)
     
        ! Register contribution of state to global aggregate variables.
        !call self%add_to_aggregate_variable(standard_variables%total_nitrogen, self%id_m)

        ! Register diagnostic variables
        call self%register_diagnostic_variable(self%id_dPAR, 'PAR', 'W m-2', 'photosynthetically active radiation')

        ! Register environmental dependencies
        call self%register_dependency(self%id_temp, standard_variables%temperature)
        call self%register_dependency(self%id_par, standard_variables%downwelling_photosynthetic_radiative_flux)
        call self%register_dependency(self%id_depth, standard_variables%bottom_depth)
        call self%register_dependency(self%id_salinity, standard_variables%practical_salinity)
        call self%register_dependency(self%id_wind, standard_variables%wind_speed)
        call self%register_dependency(self%id_I0, standard_variables%surface_downwelling_shortwave_flux)

        ! Contribute to light attenuation
        !call self%add_to_aggregate_variable(standard_variables%attenuation_coefficient_of_photosynthetic_radiative_flux, self%etb + self%es*self%SPMI)
        call self%add_to_aggregate_variable(standard_variables%attenuation_coefficient_of_photosynthetic_radiative_flux, self%id_ALG1, scale_factor=self%ea)
        call self%add_to_aggregate_variable(standard_variables%attenuation_coefficient_of_photosynthetic_radiative_flux, self%id_ALG2, scale_factor=self%ea)
        call self%add_to_aggregate_variable(standard_variables%attenuation_coefficient_of_photosynthetic_radiative_flux, self%id_POC1, scale_factor=self%ep)
        call self%add_to_aggregate_variable(standard_variables%attenuation_coefficient_of_photosynthetic_radiative_flux, self%id_POC2, scale_factor=self%ep)

        ! Register dependencies on external state variables.

    end subroutine initialize

    subroutine do(self, _ARGUMENTS_DO_)
    class (type_oxypom_oxypom), intent(in) :: self
        _DECLARE_ARGUMENTS_DO_
        real(rk), parameter :: d_per_s = 1.0_rk/86400.0_rk

        ! Starting current environmental conditions
        real(rk) :: temp
        real(rk) :: par
        real(rk) :: depth
        real(rk) :: salinity
        real(rk) :: I0
        real(rk) :: wind

		! Starting state variables
		real(rk) :: ALG1
		real(rk) :: ALG2
		real(rk) :: POC1
		real(rk) :: POC2
		real(rk) :: DOC
		real(rk) :: NH4
		real(rk) :: NO3
		real(rk) :: PON1
		real(rk) :: PON2
		real(rk) :: DON
		real(rk) :: PO4
		real(rk) :: POP1
		real(rk) :: POP2
		real(rk) :: DOP
		real(rk) :: Si
		real(rk) :: OPAL
		real(rk) :: DOxy

		! Starting auxiliary variables
		real(rk) :: fmin_tem
		real(rk) :: fres_tem
		real(rk) :: fpri_tem 
		real(rk) :: fIoi_tem 
		real(rk) :: fmno_tem 
		real(rk) :: MIN11
		real(rk) :: MIN12
		real(rk) :: MIN13
		real(rk) :: MIN21
		real(rk) :: MIN22
		real(rk) :: MIN23
		real(rk) :: MIN31
		real(rk) :: MIN32
		real(rk) :: MIN33
		real(rk) :: DEC112
		real(rk) :: DEC113
		real(rk) :: DEC123
		real(rk) :: DEC212
		real(rk) :: DEC213
		real(rk) :: DEC223
		real(rk) :: DEC312
		real(rk) :: DEC313
		real(rk) :: DEC323
		real(rk) :: fmn
		real(rk) :: fmo
		real(rk) :: frmn
		real(rk) :: frmo
		real(rk) :: fn
		real(rk) :: fp
		real(rk) :: fsi
		real(rk) :: fnut1
		real(rk) :: fnut2
		real(rk) :: MINoxy1
		real(rk) :: MINoxy2
		real(rk) :: MINoxy3
		real(rk) :: MINnit1
		real(rk) :: MINnit2
		real(rk) :: MINnit3
		real(rk) :: MORT1
		real(rk) :: MORT2
		real(rk) :: NIT
		real(rk) :: Io1
		real(rk) :: Io2
		real(rk) :: frad1
		real(rk) :: frad2
		real(rk) :: kgp1
		real(rk) :: kgp2
		real(rk) :: krsp1
		real(rk) :: krsp2
		real(rk) :: fram
		real(rk) :: DISS
		real(rk) :: nPP1
		real(rk) :: nPP2
		real(rk) :: RAM
		real(rk) :: RAP
		real(rk) :: RAS
		real(rk) :: UPH1
		real(rk) :: UPH2
		real(rk) :: UAM1
		real(rk) :: UAM2
		real(rk) :: UNI1
		real(rk) :: UNI2
		real(rk) :: USI

		! Starting derivatives state variables
		real(rk) :: d_ALG1
		real(rk) :: d_ALG2
		real(rk) :: d_POC1
		real(rk) :: d_POC2
		real(rk) :: d_DOC
		real(rk) :: d_NH4
		real(rk) :: d_NO3
		real(rk) :: d_PON1
		real(rk) :: d_PON2
		real(rk) :: d_DON
		real(rk) :: d_PO4
		real(rk) :: d_POP1
		real(rk) :: d_POP2
		real(rk) :: d_DOP
		real(rk) :: d_Si
		real(rk) :: d_OPAL
		real(rk) :: d_DOxy

    ! Enter spatial loops (if any)
    _LOOP_BEGIN_

        ! Retrieve current environmental conditions.
        _GET_(self%id_temp,temp)
        _GET_(self%id_par,par)
        _GET_BOTTOM_(self%id_depth,depth)
        _GET_(self%id_salinity,salinity)
        _GET_SURFACE_(self%id_I0,I0)
        _GET_SURFACE_(self%id_wind,wind)

        ! Retrieve current (local) state variable values.
		_GET_(self%id_ALG1,ALG1)
		_GET_(self%id_ALG2,ALG2)
		_GET_(self%id_POC1,POC1)
		_GET_(self%id_POC2,POC2)
		_GET_(self%id_DOC,DOC)
		_GET_(self%id_NH4,NH4)
		_GET_(self%id_NO3,NO3)
		_GET_(self%id_PON1,PON1)
		_GET_(self%id_PON2,PON2)
		_GET_(self%id_DON,DON)
		_GET_(self%id_PO4,PO4)
		_GET_(self%id_POP1,POP1)
		_GET_(self%id_POP2,POP2)
		_GET_(self%id_DOP,DOP)
		_GET_(self%id_Si,Si)
		_GET_(self%id_OPAL,OPAL)
		_GET_(self%id_DOxy,DOxy)

		! Starting auxiliary calculations
		fmin_tem = 1.20_rk**(temp-20.0_rk) ! temperature dependence of mineralization
		fres_tem = 1.07_rk**(temp-20.0_rk) ! temperature dependence of respiration
		fpri_tem = 1.40_rk**(temp-20.0_rk) ! temperature dependence of primary production
		fIoi_tem = 1.04_rk**(temp-20.0_rk) ! temperature dependence of optimal light intensity
		fmno_tem = 1.12_rk**(temp-20.0_rk) ! temperature dependence of demineralization of mineral nitrates

		MIN11 = self%kmin1*fmin_tem*POC1 	! mineralization rate
		MIN12 = self%kmin2*fmin_tem*POC2 	! mineralization rate
		MIN13 = self%kmin3*fmin_tem*DOC 	! mineralization rate
		MIN21 = self%kmin1*fmin_tem*PON1 	! mineralization rate
		MIN22 = self%kmin2*fmin_tem*PON2 	! mineralization rate
		MIN23 = self%kmin3*fmin_tem*DON 	! mineralization rate
		MIN31 = self%kmin1*fmin_tem*POP1 	! mineralization rate
		MIN32 = self%kmin2*fmin_tem*POP2 	! mineralization rate
		MIN33 = self%kmin3*fmin_tem*DOP 	! mineralization rate

		DEC112 = self%fdec12*MIN11 	! decomposition rate fast to slow
		DEC113 = self%fdec13*MIN12 	! decomposition rate fast to slow
		DEC123 = self%fdec23*MIN13 	! decomposition rate fast to slow
		DEC212 = self%fdec12*MIN21 	! decomposition rate fast to slow
		DEC213 = self%fdec13*MIN22 	! decomposition rate fast to slow
		DEC223 = self%fdec23*MIN23 	! decomposition rate fast to slow
		DEC312 = self%fdec12*MIN31 	! decomposition rate fast to slow
		DEC313 = self%fdec13*MIN32 	! decomposition rate fast to slow
		DEC323 = self%fdec23*MIN33 	! decomposition rate fast to slow

		fmn = NO3/(self%Ksni + NO3) * (1 - DOxy/(self%Ksoxi + DOxy)) * fmno_tem 	! contribution nitrate in mineral
		fmo = DOxy/(self%Ksoxc + DOxy) * fres_tem 	! contribution oxygen in mineral
		frmn = fmn/(fmo+fmn) 	! rel. frac. Nitrate in mineral
		frmo = 1.0_rk-frmn 	! rel. frac. oxygen in mineral
		fn = (NH4+NO3)/(NH4+NO3+self%Ksn) 	! nitrogen limitation
		fp = PO4/(PO4+self%Ksp) 	! phosphorus limitation
		fsi = Si/(Si+self%Kssi) 	! si limitation function
		fnut1 = MIN(fn,fp,fsi) 	! nutrient limitation function
		fnut2 = MIN(fn,fp) 	! nutrient limitation function

		MINoxy1 = frmo*(MIN11+MIN12+MIN13) 	! mineral oxygen consumption
		MINoxy2 = frmo*(MIN21+MIN22+MIN23) 	! mineral oxygen consumption
		MINoxy3 = frmo*(MIN31+MIN32+MIN33) 	! mineral oxygen consumption
		MINnit1 = frmn*(MIN11+MIN12+MIN13) 	! mineral denitrification
		MINnit2 = frmn*(MIN21+MIN22+MIN23) 	! mineral denitrification
		MINnit3 = frmn*(MIN31+MIN32+MIN33) 	! mineral denitrification
		MORT1 = fres_tem*self%kmrt*ALG1 	! mortality rate algae
		MORT2 = fres_tem*self%kmrt*ALG2 	! mortality rate algae
		NIT = self%knit*fres_tem*(NH4/(self%Ksam+NH4))*(DOxy/(self%Ksox+DOxy)) 	! nitrification rate
		Io1 = fIoi_tem*self%Io201 	! optimal light intensity
		Io2 = fIoi_tem*self%Io202 	! optimal light intensity
		frad1 = (1.0_rk - exp(-par/Io1)) 	! light limitation 
		frad2 = (1.0_rk - exp(-par/Io2)) 	! light limitation 
		kgp1 = frad1*fnut1*fpri_tem*self%kpp 	! gross pp rate of algae
		kgp2 = frad2*fnut2*fpri_tem*self%kpp 	! gross pp rate of algae
		krsp1 = self%fgr*kgp1+(1.0_rk-self%fgr)*fres_tem*self%kmr1 	! total respiration rate of algae
		krsp2 = self%fgr*kgp2+(1.0_rk-self%fgr)*fres_tem*self%kmr2 	! total respiration rate of algae
		fram = 1.0_rk + 0.5_rk*(1.0_rk+TANH(5.0_rk*(NH4-self%amc)))*(NH4/(NO3+NH4)-1.0_rk) 	! fraction N consumed as NH4
		DISS = self%kdiss*OPAL*(self%sieq-Si) 	! Opal dissolution rate
		nPP1 = (kgp1-krsp1)*ALG1 	! net primary production rate
		nPP2 = (kgp2-krsp2)*ALG2 	! net primary production rate
		RAM = self%fra*self%an*(MORT1+MORT2) 	! release of NH4 by autolysis
		RAP = self%fra*self%ap*(MORT1+MORT2) 	! release of PO4 by autolysis
		RAS = self%fra*self%asi*(MORT1) 	! release of Si by autolysis
		UPH1 = self%ap*nPP1 	! phosphorus uptake rate
		UPH2 = self%ap*nPP2 	! phosphorus uptake rate
		UAM1 = fram*self%an*nPP1 	! ammonia uptake rate
		UAM2 = fram*self%an*nPP2 	! ammonia uptake rate
		UNI1 = (1.0_rk-fram)*self%an*nPP1 	! nitrate uptake rate
		UNI2 = (1.0_rk-fram)*self%an*nPP2 	! nitrate uptake rate
		USI = self%asi*nPP1 	! Si uptake rate

		! Starting state variable derivation calculations
		d_ALG1 = nPP1-MORT1 	! diatom
		d_ALG2 = nPP2-MORT2 	! non-diatom
		d_POC1 = (1.0_rk-self%fra)*(MORT1+MORT2)-DEC112-DEC113-MIN11 	! POC1 
		d_POC2 = DEC112-DEC123-MIN12 	! POC2 
		d_DOC = DEC113+DEC123-MIN13 	! DOC
		d_NH4 = RAM+MIN21+MIN22+MIN23-UAM1-UAM2-NIT 	! ammonia
		d_NO3 = NIT-UNI1-UNI2-MINnit1-MINnit2-MINnit3 	! nitrate
		d_PON1 = (1.0_rk-self%fra)*self%an*(MORT1+MORT2)-DEC212-DEC213-MIN21 	! PON1
		d_PON2 = DEC212-DEC223-MIN22 	! PON2 
		d_DON = DEC213+DEC223-MIN23 	! DON
		d_PO4 = RAP+MIN31+MIN32+MIN33-UPH1-UPH2 	! phosphate
		d_POP1 = (1.0_rk-self%fra)*self%ap*(MORT1+MORT2)-DEC312-DEC313-MIN31 	! POP1 
		d_POP2 = DEC312-DEC323-MIN32 	! POP2 
		d_DOP = DEC313+DEC323-MIN33 	! DOP
		d_Si = RAS+DISS-USI 	! Silicate
		d_OPAL = (1.0_rk-self%fra)*self%asi*MORT1-DISS 	! opal
		d_DOxy = nPP1+nPP2 - MINoxy1-MINoxy2-MINoxy3 -2.0_rk*NIT 	! dissolved oxygen

		! Add sources
		_ADD_SOURCE_(self%id_ALG1,d_ALG1*d_per_s)
		_ADD_SOURCE_(self%id_ALG2,d_ALG2*d_per_s)
		_ADD_SOURCE_(self%id_POC1,d_POC1*d_per_s)
		_ADD_SOURCE_(self%id_POC2,d_POC2*d_per_s)
		_ADD_SOURCE_(self%id_DOC,d_DOC*d_per_s)
		_ADD_SOURCE_(self%id_NH4,d_NH4*d_per_s)
		_ADD_SOURCE_(self%id_NO3,d_NO3*d_per_s)
		_ADD_SOURCE_(self%id_PON1,d_PON1*d_per_s)
		_ADD_SOURCE_(self%id_PON2,d_PON2*d_per_s)
		_ADD_SOURCE_(self%id_DON,d_DON*d_per_s)
		_ADD_SOURCE_(self%id_PO4,d_PO4*d_per_s)
		_ADD_SOURCE_(self%id_POP1,d_POP1*d_per_s)
		_ADD_SOURCE_(self%id_POP2,d_POP2*d_per_s)
		_ADD_SOURCE_(self%id_DOP,d_DOP*d_per_s)
		_ADD_SOURCE_(self%id_Si,d_Si*d_per_s)
		_ADD_SOURCE_(self%id_OPAL,d_OPAL*d_per_s)
		_ADD_SOURCE_(self%id_DOxy,d_DOxy*d_per_s)

		_SET_DIAGNOSTIC_(self%id_dPAR,par)

        ! Leave spatial loops (if any)
        _LOOP_END_
    end subroutine do

    subroutine do_surface(self,_ARGUMENTS_DO_SURFACE_)
      class (type_oxypom_oxypom), intent(in) :: self
      	_DECLARE_ARGUMENTS_DO_SURFACE_
        real(rk), parameter :: d_per_s = 1.0_rk/86400.0_rk
      	real(rk) :: temp 
      	real(rk) :: abs_temp
      	real(rk) :: salinity
      	real(rk) :: wind
      	real(rk) :: klrear
      	real(rk) :: DOxy
      	real(rk) :: OSAT
        real(rk) :: SOXY

      	_HORIZONTAL_LOOP_BEGIN_
 	        _GET_(self%id_DOxy,DOxy)
	        _GET_(self%id_temp,temp)
	        _GET_(self%id_salinity,salinity)
	        _GET_SURFACE_(self%id_wind,wind)

	        ! As in ERSEM, taken from WEISS 1970 DEEP SEA RES 17, 721-735.
			abs_temp = temp + 273.15_rk 	! absolute temperature in Kelvin

			! oxigen saturation in accordingly to Weiss 1970
			OSAT = -173.4292_rk + 249.6339_rk * (100._rk/abs_temp) + 143.3483_rk * log(abs_temp/100._rk) &
            	-21.8492_rk * (abs_temp/100._rk) &
                + salinity * ( -0.033096_rk + 0.014259_rk * (abs_temp/100._rk) -0.0017_rk * ((abs_temp/100._rk)**2)) 	

			SOXY = EXP(OSAT) * 1000._rk / ( (8.3145_rk * 298.15_rk / 101325_rk) *1000._rk) 	! oxygen saturation

         	if (wind .lt. 0._rk) wind = 0._rk

         	if (wind .gt. 11._rk) then
            klrear = SQRT((1953.4_rk-128._rk*temp+3.9918_rk*temp**2-  &
               0.050091_rk*temp**3)/660._rk) * (0.02383_rk * wind**3)
         	else
            klrear = SQRT((1953.4_rk-128._rk*temp+3.9918_rk*temp**2- &
               0.050091_rk*temp**3)/660._rk) * (0.31_rk * wind**2)
         	endif

         	! units of ko2 converted from cm/hr to m/day
         	klrear = klrear*(24._rk/100._rk)

         	_SET_SURFACE_EXCHANGE_(self%id_DOxy,klrear*(SOXY-DOxy)*d_per_s)

      _HORIZONTAL_LOOP_END_
   end subroutine
end module oxypom_oxypom

