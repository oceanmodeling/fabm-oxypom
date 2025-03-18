!! SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
!! SPDX-License-Identifier: Apache-2.0
!! SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

#include "fabm_driver.h"

module dobgcp_diamo
    use fabm_types
    implicit none
    private

    type, extends(type_base_model), public :: type_dobgcp_diamo
        ! External dependencies
        type (type_dependency_id) :: id_temp
        type (type_dependency_id) :: id_par
        type (type_dependency_id) :: id_depth
        type (type_dependency_id) :: id_salinity
        type (type_surface_dependency_id) :: id_wind
        type (type_surface_dependency_id) :: id_I0
        ! Variable identifiers
		type (type_state_variable_id) :: id_PHY
		type (type_state_variable_id) :: id_DET
		type (type_state_variable_id) :: id_OXY
		! Diagnostic variables
	    type (type_diagnostic_variable_id) :: id_dPAR
		! Model parameters
		real(rk) :: tempRef
		real(rk) :: SIM
		real(rk) :: sinkingPHY
		real(rk) :: sinkingDET
		real(rk) :: attenuationWater
		real(rk) :: attenuationSIM
		real(rk) :: attenuationPHY
		real(rk) :: attenuationDET
		real(rk) :: synthesisRef
		real(rk) :: synthesisQ10
		real(rk) :: synthesisPar
		real(rk) :: respirationRef
		real(rk) :: respirationQ10
		real(rk) :: aggregationRef
		real(rk) :: aggregationQ10
		real(rk) :: aggregationPar
		real(rk) :: kSIM
		real(rk) :: mineralizationRef
		real(rk) :: mineralizationQ10
		real(rk) :: kOXY
   
    contains
        procedure :: initialize
        procedure :: do
        procedure :: do_surface
    end type

contains

    subroutine initialize(self, configunit)
        class (type_dobgcp_diamo), intent(inout), target :: self
        integer, intent(in) :: configunit
        
        real(rk), parameter :: d_per_s = 1.0_rk/86400.0_rk

        ! Store parameter values in our own derived type
        ! All rates must be provided in values per day and are converted here to values per second.
		call self%get_parameter(self%tempRef, 'tempRef', 'C', 'reference temperature', default=20.0_rk)
		call self%get_parameter(self%SIM, 'SIM', 'g m-3', 'inorganic suspended particular matter concentration', default=47.0_rk)
		call self%get_parameter(self%sinkingPHY, 'sinkingPHY', 'm d-1', 'sinking velocity of phytoplankton', default=-0.1_rk)
		call self%get_parameter(self%sinkingDET, 'sinkingDET', 'm d-1', 'sinking velocity of detritus', default=-0.3_rk)
		call self%get_parameter(self%attenuationSIM, 'attenuationSIM', 'm-1', 'light extinction suspended inorganic matter', default=0.08_rk)
		call self%get_parameter(self%attenuationPHY, 'attenuationPHY', 'm2 mmol C-1', 'specific light extinction coeff. Algae', default=0.0012_rk)
		call self%get_parameter(self%attenuationDET, 'attenuationDET', 'm2 mmol C-1', 'specific light extinction coeff. POC', default=0.0012_rk)
		call self%get_parameter(self%synthesisRef, 'synthesisRef', 'd-1', 'reference photosynthesis rate', default=1.0_rk)
		call self%get_parameter(self%synthesisQ10, 'synthesisQ10', '--', 'temperature sensitivity of photosynthesis', default=1.04_rk)
		call self%get_parameter(self%synthesisPar, 'synthesisPar', 'm2 W-1', 'light sensitivity of photosynthesis', default=50.0_rk)
		call self%get_parameter(self%respirationRef, 'respirationRef', 'd-1', 'reference respiration rate', default=1.0_rk)
		call self%get_parameter(self%respirationQ10, 'respirationQ10', '--', 'temperature sensitivity of respiration', default=1.7_rk)
		call self%get_parameter(self%aggregationRef, 'aggregationRef', 'd-1 m3 mmol C-1', 'reference aggregation rate per unit of phytoplankton', default=0.1_rk)
		call self%get_parameter(self%aggregationQ10, 'aggregationQ10', '--', 'temperature sensitivity of aggregation', default=1.04_rk)
		call self%get_parameter(self%aggregationPar, 'aggregationPar', 'm2 W-1', 'reference value to rescaling light to particles ', default=50.0_rk)
		call self%get_parameter(self%kSIM, 'kSIM', 'mmol C g-1', 'equivalence of SIM to carbon in aggregation for unit consistency', default=0.07_rk)
		call self%get_parameter(self%mineralizationRef, 'mineralizationRef', 'd-1', 'reference mineralization rate', default=1.0_rk)
		call self%get_parameter(self%mineralizationQ10, 'mineralizationQ10', '--', 'temperature sensitivity of mineralization', default=1.7_rk)
		call self%get_parameter(self%kOXY, 'kOXY', 'mmol O2 mmol C-1', 'equivalence of carbon to oxygen', default=2.667_rk)
		! Register state variables
		call self%register_state_variable(self%id_PHY, 'PHY', 'mmol C m-3', 'phytoplankton concentration', 1.80_rk, minimum=0.0_rk, maximum=1000.0_rk, vertical_movement=self%sinkingPHY*d_per_s)
		call self%register_state_variable(self%id_DET, 'DET', 'mmol C m-3', 'detritus concentration', 1.80_rk, minimum=0.0_rk, maximum=1000.0_rk, vertical_movement=self%sinkingDET*d_per_s)
		call self%register_state_variable(self%id_OXY, 'OXY', 'mmol O2 m-3', 'oxygen concentration', 400.0_rk, minimum=0.0_rk, maximum=600.0_rk, vertical_movement=0.0*d_per_s)
     
        ! Register contribution of state to global aggregate variables.
        !call self%add_to_aggregate_variable(standard_variables%total_nitrogen, self%id_m)

        ! Register diagnostic variables
        call self%register_diagnostic_variable(self%id_dPAR, 'PAR', 'W m-2',        'photosynthetically active radiation')

        ! Register environmental dependencies
        call self%register_dependency(self%id_temp, standard_variables%temperature)
        call self%register_dependency(self%id_par, standard_variables%downwelling_photosynthetic_radiative_flux)
        call self%register_dependency(self%id_depth, standard_variables%depth)
        call self%register_dependency(self%id_wind, standard_variables%wind_speed)
        call self%register_dependency(self%id_I0, standard_variables%surface_downwelling_shortwave_flux)

		! Contribute to light attenuation
		call self%add_to_aggregate_variable(standard_variables%attenuation_coefficient_of_photosynthetic_radiative_flux, self%id_PHY, scale_factor=self%attenuationPHY)
		call self%add_to_aggregate_variable(standard_variables%attenuation_coefficient_of_photosynthetic_radiative_flux, self%id_DET, scale_factor=self%attenuationDET)
		call self%add_to_aggregate_variable(standard_variables%attenuation_coefficient_of_photosynthetic_radiative_flux, self%id_OXY, scale_factor=0.0_rk)
		call self%add_to_aggregate_variable(standard_variables%attenuation_coefficient_of_photosynthetic_radiative_flux, self%attenuationSIM*self%SIM)

    ! Register dependencies on external state variables.

    end subroutine initialize

    subroutine do(self, _ARGUMENTS_DO_)
    class (type_dobgcp_diamo), intent(in) :: self
        _DECLARE_ARGUMENTS_DO_
        real(rk), parameter :: d_per_s = 1.0_rk/86400.0_rk

        ! Starting current environmental conditions
        real(rk) :: temp
        real(rk) :: par
        real(rk) :: depth
        real(rk) :: salinity
        real(rk) :: wind
        real(rk) :: I0
		! Starting state variables
		real(rk) :: PHY
		real(rk) :: DET
		real(rk) :: OXY
		! Starting auxiliary variables
		real(rk) :: synthesis
		real(rk) :: respiration
		real(rk) :: aggregation
		real(rk) :: mineralization
		! Starting derivatives state variables
		real(rk) :: d_PHY
		real(rk) :: d_DET
		real(rk) :: d_OXY

    ! Enter spatial loops (if any)
    _LOOP_BEGIN_

        ! Retrieve current environmental conditions.
        _GET_(self%id_temp,temp)
        _GET_(self%id_par,par)
        _GET_(self%id_depth,depth)
        _GET_(self%id_salinity,salinity)
        _GET_SURFACE_(self%id_I0,I0)
        _GET_SURFACE_(self%id_wind,wind)

        ! Retrieve current (local) state variable values.
		_GET_(self%id_PHY,PHY)
		_GET_(self%id_DET,DET)
		_GET_(self%id_OXY,OXY)
		! Starting auxiliary calculations
		synthesis = self%synthesisRef*self%synthesisQ10**(temp-self%tempRef)*(1.0_rk-exp(-self%synthesisPar*par))*PHY 	! photosynthesis rate
		respiration = self%respirationRef*self%respirationQ10**(temp-self%tempRef)*PHY 	! respiration rate
		aggregation = self%aggregationRef*self%aggregationQ10**(temp-self%tempRef)*PHY*(DET+self%kSIM*self%SIM*exp(-self%aggregationPar*par)) 	! aggregation rate
		mineralization = self%mineralizationRef*self%mineralizationQ10**(temp-self%tempRef)*DET 	! mineralization rate
		! Starting state variable derivation calculations
		d_PHY = synthesis - respiration - aggregation 	! phytoplankton concentration
		d_DET = aggregation - mineralization 	! detritus concentration
		d_OXY = self%kOXY*(synthesis - respiration - mineralization) 	! oxygen concentration
		! Add sources
		_ADD_SOURCE_(self%id_PHY,d_PHY*d_per_s)
		_ADD_SOURCE_(self%id_DET,d_DET*d_per_s)
		_ADD_SOURCE_(self%id_OXY,d_OXY*d_per_s)
        
        _SET_DIAGNOSTIC_(self%id_dPAR,par)

        ! Leave spatial loops (if any)
        _LOOP_END_
    end subroutine do

    subroutine do_surface(self,_ARGUMENTS_DO_SURFACE_)
      class (type_dobgcp_diamo), intent(in) :: self
        _DECLARE_ARGUMENTS_DO_SURFACE_
        real(rk), parameter :: d_per_s = 1.0_rk/86400.0_rk
        real(rk) :: temp 
        real(rk) :: abs_temp
        real(rk) :: salinity
        real(rk) :: wind
        real(rk) :: klrear
        real(rk) :: OXY
        real(rk) :: OSAT
        real(rk) :: SOXY
      
        _HORIZONTAL_LOOP_BEGIN_
            _GET_(self%id_OXY,OXY)
            _GET_(self%id_temp,temp)
            _GET_(self%id_salinity,salinity)
            _GET_SURFACE_(self%id_wind,wind)

            ! As in ERSEM, taken from WEISS 1970 DEEP SEA RES 17, 721-735.
            abs_temp = temp + 273.15_rk     ! absolute temperature in Kelvin

            ! oxigen saturation in accordingly to Weiss 1970
            OSAT = -173.4292_rk + 249.6339_rk * (100._rk/abs_temp) + 143.3483_rk * log(abs_temp/100._rk) &
                -21.8492_rk * (abs_temp/100._rk) &
                + salinity * ( -0.033096_rk + 0.014259_rk * (abs_temp/100._rk) -0.0017_rk * ((abs_temp/100._rk)**2))   

            SOXY = EXP(OSAT) * 1000._rk / ( (8.3145_rk * 298.15_rk / 101325_rk) *1000._rk)  ! oxygen saturation

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

            _SET_SURFACE_EXCHANGE_(self%id_OXY,klrear*(SOXY-OXY)*d_per_s)

      _HORIZONTAL_LOOP_END_
   end subroutine
end module dobgcp_diamo