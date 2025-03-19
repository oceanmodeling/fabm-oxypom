!! SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
!! SPDX-License-Identifier: GPL-2.0-only
!! SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

#include "fabm_driver.h"

! This is a FABM implementation of the two-band light model used in
! the General Ocean Turbulence Model (GOTM)
!
! It distinguishes two wavebands:
! * visible (equivalent to photosynthetically activate radation, PAR, 400 - 700 nm)
! * non-visible, which combines ultraviolet (< 400 nm) and infrared (> 700 nm)
! The non-visible fraction is generally absorbed close to the surface.
! The visible fraction typically penetrates deeper into the water.
! Attenuation of the visible band is influenced by FABM variables that contribute to
! standard_variables%attenuation_coefficient_of_photosynthetic_radiative_flux
! (as well as by the background attenuation set by parameter g2)
!
! The model is driven by downwelling shortwave radiation just below the water surface,
! which in FABM is denoted with standard_variables%surface_downwelling_shortwave_flux
! This is the radiation left after reflection by the surface [albedo] is accounted for.

module oxypom_light

   use fabm_types

   implicit none

   private

   type, extends(type_base_model), public :: type_oxypom_light
      ! Identifiers for dependencies [model inputs]
      type (type_surface_dependency_id) :: id_swr0 ! Surface shortwave radiation
      type (type_dependency_id)         :: id_dz   ! Cell thickness
      type (type_dependency_id)         :: id_ext  ! Attentuation coefficient for PAR

      ! Identifiers for diagnostic variables [model outputs]
      type (type_diagnostic_variable_id)         :: id_par  ! Photosynthetically active radiation
      type (type_diagnostic_variable_id)         :: id_swr  ! Shortwave radiation
      type (type_surface_diagnostic_variable_id) :: id_par0 ! Surface photosynthetically active radiation

      ! Parameters
      real(rk) :: a, g1, g2
   contains
      ! Model procedures
      procedure :: initialize
      procedure :: do_column
   end type type_oxypom_light

contains

   subroutine initialize(self, configunit)
      class (type_oxypom_light), intent(inout), target :: self
      integer,                 intent(in)            :: configunit

      call self%get_parameter(self%a,  'a',  '-','non-visible fraction of shortwave radiation', default=0.58_rk) 
      call self%get_parameter(self%g1, 'g1', 'm','e-folding depth of non-visible fraction',     default=0.35_rk)
      call self%get_parameter(self%g2, 'g2', 'm','e-folding depth of visible fraction',         default=23.0_rk) 

      ! Register diagnostic variables
      call self%register_diagnostic_variable(self%id_swr, 'swr', 'W m-2', 'shortwave radiation', &
         standard_variable=standard_variables%downwelling_shortwave_flux, source=source_do_column)
      call self%register_diagnostic_variable(self%id_par, 'par', 'W m-2', 'photosynthetically active radiation', &
         standard_variable=standard_variables%downwelling_photosynthetic_radiative_flux, source=source_do_column)
      call self%register_diagnostic_variable(self%id_par0, 'par0', 'W m-2', 'surface photosynthetically active radiation', &
         standard_variable=standard_variables%surface_downwelling_photosynthetic_radiative_flux, source=source_do_column)

      ! Register environmental dependencies (temperature, shortwave radiation)
      call self%register_dependency(self%id_swr0, standard_variables%surface_downwelling_shortwave_flux)
      call self%register_dependency(self%id_ext,  standard_variables%attenuation_coefficient_of_photosynthetic_radiative_flux)
      call self%register_dependency(self%id_dz,   standard_variables%cell_thickness)
   end subroutine
   
   subroutine do_column(self, _ARGUMENTS_DO_COLUMN_)
      class (type_oxypom_light), intent(in) :: self
      _DECLARE_ARGUMENTS_DO_COLUMN_

      real(rk) :: swr0, dz, h, one_over_g2, swr, par, z, ext

      _GET_SURFACE_(self%id_swr0,swr0)
      _SET_SURFACE_DIAGNOSTIC_(self%id_par0,swr0 * (1.0_rk - self%a))
      z = 0.0_rk
      one_over_g2 = 1.0_rk/self%g2
      par = swr0 * (1.0_rk - self%a)
      _DOWNWARD_LOOP_BEGIN_
         _GET_(self%id_dz,dz)     ! Layer height (m)
         _GET_(self%id_ext,ext)   ! PAR attenuation (m-1)

         ! center of mass of light weighted layer
         h  = dz * 0.5_rk  - 0.333_rk * (ext + one_over_g2) * dz * dz !second order approximation
         !h = -log((1-exp(-(ext + one_over_g2)*dz))/((ext + one_over_g2)*dz))/(ext + one_over_g2) ! exact solution
         if(h .lt. (0.2_rk*dz)) h = 0.2_rk * dz 

         ! Set depth to centre of layer
         z = z + h

         ! Calculate photosynthetically active radiation (PAR), shortwave radiation, and PAR attenuation.
         par = par * exp(-h * (one_over_g2 + ext))
         swr = par + swr0 * self%a * exp(-z / self%g1)

         ! Move to bottom of layer
         z = z + dz - h

         _SET_DIAGNOSTIC_(self%id_swr,swr) ! Shortwave radiation at layer centre
         _SET_DIAGNOSTIC_(self%id_par,par) ! Photosynthetically active radiation at layer centre
         
         ! calculate par in bottom of layer/surface of next layer
         par = par*exp(-(dz-h) * (one_over_g2 + ext))
      _DOWNWARD_LOOP_END_
   end subroutine do_column

end module oxypom_light
