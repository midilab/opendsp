# Build

TEMPLATECONF=../../meta-opendsp/conf source oe-init-build-env
bitbake opendsp-base-image

# Depends

openembedded-core
meta-openembedded:
  + meta-oe
  + meta-python
  + meta-multimedia
  + meta-networking
