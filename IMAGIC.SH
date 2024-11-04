# преобразование в формат 16-цветов BMP с помощью пакета ImageMagic

convert cenbibl2.jpg -resize 320x200 -colors 16 ppm:- | ppmtobmp -bpp=4 > cenbibl2.bmp

convert cenbibl2.jpg -colors 16 ppm:- | ppmtobmp -bpp=4 > cenbibl2.bmp
