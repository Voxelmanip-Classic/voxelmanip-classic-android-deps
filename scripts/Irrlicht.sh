#!/bin/bash -e
irrlicht_ver=1.9.0mt10
png_ver=1.6.37

download () {
	if [ ! -d irrlicht/.git ]; then
		git clone https://github.com/rollerozxa/irrlicht-vmc irrlicht
		#pushd irrlicht
		#git checkout $irrlicht_ver
		#popd
	fi
	get_tar_archive libpng "https://download.sourceforge.net/libpng/libpng-${png_ver}.tar.gz"
}

build () {
	# Build libpng first because Irrlicht needs it
	mkdir -p libpng
	pushd libpng
	$srcdir/libpng/configure --host=$CROSS_PREFIX
	make && make DESTDIR=$PWD install
	popd

	local libpng=$PWD/libpng/usr/local/lib/libpng.a
	cmake $srcdir/irrlicht "${CMAKE_FLAGS[@]}" \
		-DBUILD_SHARED_LIBS=OFF \
		-DPNG_LIBRARY=$libpng \
		-DPNG_PNG_INCLUDE_DIR=$(dirname "$libpng")/../include
	make

	cp -p lib/Android/libIrrlichtMt.a $libpng $pkgdir/
	cp -a $srcdir/irrlicht/include $pkgdir/include
	cp -a $srcdir/irrlicht/media/Shaders $pkgdir/Shaders
}

#build pls
