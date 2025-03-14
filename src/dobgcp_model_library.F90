!! SPDX-FileCopyrightText: 2025 Helmholtz-Zentrum hereon GmbH
!! SPDX-License-Identifier: CC0-1.0
!! SPDX-FileContributor Ovidio Garcia-Oliva <ovidio.garcia@hereon.de>

module dobgcp_model_library

   use fabm_types, only: type_base_model_factory, type_base_model

   implicit none

   private

   type, extends(type_base_model_factory) :: type_factory
   contains
      procedure :: create
   end type

   type (type_factory), save, target, public :: dobgcp_model_factory

contains

   subroutine create(self, name, model)
   use dobgcp_oxypom
   use dobgcp_diamo
   use dobgcp_light
   ! Add use statements for new models here

      class (type_factory), intent(in) :: self
      character(*),         intent(in) :: name
      class (type_base_model), pointer :: model

      select case (name)
         ! Add case statements for new models here
         case ('oxypom'); allocate(type_dobgcp_oxypom::model)
         case ('diamo'); allocate(type_dobgcp_diamo::model)
         case ('light'); allocate(type_dobgcp_light::model)
         case default
            call self%type_base_model_factory%create(name, model)
      end select

   end subroutine create

end module
