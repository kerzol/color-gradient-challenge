#!/bin/bash

convert ../image.ppm -compress none -crop 596x1+0+20  +repage  image-crop.ppm

tail -n+4 image-crop.ppm  | sed 's/ /\n/g' | grep -v '^$' > tmp

sed -n 1~3p tmp  > tmp-red
sed -n 2~3p tmp  > tmp-green
sed -n 3~3p tmp  > tmp-blue

paste tmp-red tmp-green tmp-blue > tmp


(cat <<EOF
read.table("tmp") -> d
t(rgb2hsv(t(d))) -> hsv
write.table(floor(hsv*255), file="tmp-hsv", col.names=FALSE, row.names=FALSE)
png('new-image-r.png')
plot(hsv[,1], hsv[,3], col=hsv(hsv[,1],hsv[,2],hsv[,3]),cex=2,pch=16)
dev.off()
EOF
) | R --no-save


paste tmp-hsv tmp | sort -g | awk '{print $4,$5,$6}' > tmp-sorted

echo P3 > new-image.ppm
echo 596 200 >> new-image.ppm
echo 255 >> new-image.ppm
for i in {1..200}; do
    cat tmp-sorted >> new-image.ppm
done

convert new-image.ppm new-image.png

display new-image.png new-image-r.png
