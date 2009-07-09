


! Copyright (C) 2007 J. K. Dewhurst, S. Sharma and C. Ambrosch-Draxl.
! This file is distributed under the terms of the GNU General Public License.
! See the file COPYING for license details.


subroutine projsbf
use modmain
use modinput
implicit none
! local variables
integer::is, ia, ias, ir
integer::idm, lmax, lm
real(8)::t1
complex(8) zrho0
! automatic arrays
real(8)::zn(nspecies)
! allocatable arrays
real(8), allocatable :: rvfmt(:, :, :, :)
real(8), allocatable :: rvfir(:, :)
real(8), allocatable :: rfmt(:, :, :)
real(8), allocatable :: rfir(:)
real(8), allocatable :: grfmt(:, :, :, :)
real(8), allocatable :: grfir(:, :)
real(8), allocatable :: jlgr(:, :, :)
complex(8), allocatable :: zrhomt(:, :, :)
complex(8), allocatable :: zrhoir(:)
complex(8), allocatable :: zvclmt(:, :, :)
complex(8), allocatable :: zvclir(:)
allocate(rvfmt(lmmaxvr, nrmtmax, natmtot, 3))
allocate(rvfir(ngrtot, 3))
allocate(rfmt(lmmaxvr, nrmtmax, natmtot))
allocate(rfir(ngrtot))
allocate(grfmt(lmmaxvr, nrmtmax, natmtot, 3))
allocate(grfir(ngrtot, 3))
allocate(jlgr(0:input%groundstate%lmaxvr+input%groundstate%npsden+1, ngvec, nspecies))
allocate(zrhomt(lmmaxvr, nrmtmax, natmtot))
allocate(zrhoir(ngrtot))
allocate(zvclmt(lmmaxvr, nrmtmax, natmtot))
allocate(zvclir(ngrtot))
if (.not.associated(input%groundstate%spin)) then
  write(*, *)
  write(*, '("Error(projsbf): spin-unpolarised field is zero")')
  write(*, *)
  stop
end if
if (ncmag) then
! non-collinear
  rvfmt(:, :, :, :)=bxcmt(:, :, :, :)
  rvfir(:, :)=bxcir(:, :)
else
! collinear
  rvfmt(:, :, :, 1:2)=0.d0
  rvfir(:, 1:2)=0.d0
  rvfmt(:, :, :, 3)=bxcmt(:, :, :, 1)
  rvfir(:, 3)=bxcir(:, 1)
end if
! compute the divergence of B-field
rfmt(:, :, :)=0.d0
rfir(:)=0.d0
do idm=1, 3
  call gradrf(rvfmt(:, :, :, idm), rvfir(:, idm), grfmt, grfir)
  do is=1, nspecies
    do ia=1, natoms(is)
      ias=idxas(ia, is)
      do ir=1, nrmt(is)
	rfmt(:, ir, ias)=rfmt(:, ir, ias)+grfmt(:, ir, ias, idm)
      end do
    end do
  end do
  rfir(:)=rfir(:)+grfir(:, idm)
end do
! divide by -4*pi
t1=-1.d0/fourpi
rfmt(:, :, :)=t1*rfmt(:, :, :)
rfir(:)=t1*rfir(:)
! convert real muffin-tin divergence to complex spherical harmonic expansion
do is=1, nspecies
  do ia=1, natoms(is)
    ias=idxas(ia, is)
    do ir=1, nrmt(is)
      call rtozflm(input%groundstate%lmaxvr, rfmt(:, ir, ias), zrhomt(:, ir, ias))
    end do
  end do
end do
! store real interstitial divergence in a complex array
zrhoir(:)=rfir(:)
! set the point charges to zero
zn(:)=0.d0
! compute the required spherical Bessel functions
lmax=input%groundstate%lmaxvr+input%groundstate%npsden+1
call genjlgpr(lmax, gc, jlgr)
! solve the complex Poisson's equation
call zpotcoul(nrmt, nrmtmax, spnrmax, spr, 1, gc, jlgr, ylmg, sfacg, zn, zrhomt, zrhoir, &
 zvclmt, zvclir, zrho0)
! convert complex muffin-tin potential to real spherical harmonic expansion
do is=1, nspecies
  do ia=1, natoms(is)
    ias=idxas(ia, is)
    do ir=1, nrmt(is)
      call ztorflm(input%groundstate%lmaxvr, zvclmt(:, ir, ias), rfmt(:, ir, ias))
    end do
  end do
end do
! store complex interstitial potential in real array
rfir(:)=dble(zvclir(:))
! compute the gradient
call gradrf(rfmt, rfir, grfmt, grfir)
! subtract gradient from existing B-field
if (ncmag) then
! non-collinear
  bxcmt(:, :, :, :)=bxcmt(:, :, :, :)-grfmt(:, :, :, :)
  bxcir(:, :)=bxcir(:, :)-grfir(:, :)
else
! collinear
  bxcmt(:, :, :, 1)=bxcmt(:, :, :, 1)-grfmt(:, :, :, 3)
  bxcir(:, 1)=bxcir(:, 1)-grfir(:, 3)
end if
! remove numerical noise from the muffin-tin B-field
do idm=1, ndmag
  do is=1, nspecies
    do ia=1, natoms(is)
      ias=idxas(ia, is)
      do lm=1, lmmaxvr
	call fsmooth(10, nrmt(is), lmmaxvr, bxcmt(lm, 1, ias, idm))
      end do
    end do
  end do
end do
deallocate(rvfmt, rvfir, rfmt, rfir, grfmt, grfir, jlgr)
deallocate(zrhomt, zrhoir, zvclmt, zvclir)
return
end subroutine
