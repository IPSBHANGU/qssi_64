#For QSSI_64, we build only the system image. Here we explicitly set the images
#we build so there is no confusion.

TARGET_BOARD_PLATFORM := qssi
TARGET_BOARD_SUFFIX := _64
TARGET_BOOTLOADER_BOARD_NAME := qssi_64

# Opt out of 16K alignment changes
PRODUCT_MAX_PAGE_SIZE_SUPPORTED := 4096

#Flag to Enable 64 bit only configuration
TARGET_SUPPORTS_64_BIT_ONLY := true

# Skip VINTF checks for kernel configs since we do not have kernel source
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false

#Enable product partition Native I/F. It is automatically set to current if
#the shipping API level for the target is greater than 29
PRODUCT_PRODUCT_VNDK_VERSION := current

RELAX_USES_LIBRARY_CHECK := true
NEED_AIDL_NDK_PLATFORM_BACKEND := true

#Enable product partition Java I/F. It is automatically set to true if
#the shipping API level for the target is greater than 29
PRODUCT_ENFORCE_PRODUCT_PARTITION_INTERFACE := true

PRODUCT_BUILD_SYSTEM_IMAGE := true
PRODUCT_BUILD_SYSTEM_OTHER_IMAGE := false
PRODUCT_BUILD_VENDOR_IMAGE := false
PRODUCT_BUILD_SYSTEM_EXT_IMAGE := false
PRODUCT_BUILD_ODM_IMAGE := false
PRODUCT_BUILD_CACHE_IMAGE := false
PRODUCT_BUILD_USERDATA_IMAGE := false

# Enable debugfs restrictions
PRODUCT_SET_DEBUGFS_RESTRICTIONS := true

#Also, there is no need to build an OTA package as this will be done later
#when we combine this system build with the non-system images.
TARGET_SKIP_OTA_PACKAGE := true

# Enable AVB 2.0
BOARD_AVB_ENABLE := true

#### Dynamic Partition Handling

####

# Retain the earlier default behavior i.e. ota config (dynamic partition was disabled if not set explicitly), so set
# SHIPPING_API_LEVEL to 28 if it was not set earlier (this is generally set earlier via build.sh per-target)
SHIPPING_API_LEVEL := 34

$(call inherit-product-if-exists, vendor/qcom/defs/product-defs/system/cne_url*.mk)

#### Turning BOARD_DYNAMIC_PARTITION_ENABLE flag to TRUE will enable dynamic partition/super image creation.
# Enable Dynamic partitions only for Q new launch devices and beyond.
ifeq (true,$(call math_gt_or_eq,$(SHIPPING_API_LEVEL),29))
  BOARD_DYNAMIC_PARTITION_ENABLE ?= true
  PRODUCT_SHIPPING_API_LEVEL := $(SHIPPING_API_LEVEL)
else ifeq ($(SHIPPING_API_LEVEL),28)
  BOARD_DYNAMIC_PARTITION_ENABLE ?= false
  $(call inherit-product, build/make/target/product/product_launched_with_p.mk)
endif

ifneq ($(strip $(BOARD_DYNAMIC_PARTITION_ENABLE)),true)
# Enable chain partition for system, to facilitate system-only OTA in Treble.
BOARD_AVB_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_SYSTEM_ROLLBACK_INDEX := 0
BOARD_AVB_SYSTEM_ROLLBACK_INDEX_LOCATION := 2
PRODUCT_BUILD_RAMDISK_IMAGE := false
PRODUCT_BUILD_PRODUCT_IMAGE := false
else
PRODUCT_USE_DYNAMIC_PARTITIONS := true
# Disable building the SUPER partition in this build. SUPER should be built
# after QSSI_64 has been merged with the SoC build.
PRODUCT_BUILD_SYSTEM_EXT_IMAGE := true
PRODUCT_BUILD_PRODUCT_IMAGE := true
PRODUCT_BUILD_SUPER_PARTITION := false
PRODUCT_BUILD_RAMDISK_IMAGE := true
BOARD_AVB_VBMETA_SYSTEM := system system_ext product
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2
endif
#### Dynamic Partition Handling

PRODUCT_PRODUCT_PROPERTIES += \
    remote_provisioning.enable_rkpd=true \
    remote_provisioning.hostname=remoteprovisioning.googleapis.com \

PRODUCT_SOONG_NAMESPACES += \
    hardware/google/av \
    hardware/google/interfaces

VENDOR_QTI_PLATFORM := qssi_64
VENDOR_QTI_DEVICE := qssi_64

#QSSI 64 bit configuration
#Single system image project structure
TARGET_USES_QSSI := true

TARGET_USES_NEW_ION := true

ENABLE_AB ?= true

TARGET_DEFINES_DALVIK_HEAP := true
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, device/qcom/qssi_64/common64.mk)

#Inherit all except heap growth limit from phone-xhdpi-2048-dalvik-heap.mk
PRODUCT_PROPERTY_OVERRIDES  += \
     dalvik.vm.heapstartsize=8m \
     dalvik.vm.heapsize=512m \
     dalvik.vm.heaptargetutilization=0.75 \
     dalvik.vm.heapminfree=512k \
     dalvik.vm.heapmaxfree=8m


PRODUCT_NAME := $(VENDOR_QTI_DEVICE)
PRODUCT_DEVICE := $(VENDOR_QTI_DEVICE)
PRODUCT_BRAND := qti
PRODUCT_MODEL := qssi system image for arm64

PRODUCT_EXTRA_VNDK_VERSIONS := 30 31 32 33

#Initial bringup flags
TARGET_USES_AOSP := false
TARGET_USES_AOSP_FOR_AUDIO := false
TARGET_USES_QCOM_BSP := false

# RRO configuration
TARGET_USES_RRO := true

TARGET_USES_NQ_NFC := true


# default is nosdcard, S/W button enabled in resource
PRODUCT_CHARACTERISTICS := nosdcard
BOARD_FRP_PARTITION_NAME := frp

PRODUCT_PACKAGES += qspa_system.rc qspa_default.rc

#Android EGL implementation
PRODUCT_PACKAGES += libGLES_android
PRODUCT_PACKAGES += fsck.exfat
PRODUCT_PACKAGES += mkfs.exfat

PRODUCT_BOOT_JARS += tcmiface
PRODUCT_BOOT_JARS += telephony-ext
PRODUCT_PACKAGES += telephony-ext

TARGET_ENABLE_QC_AV_ENHANCEMENTS := false

TARGET_SYSTEM_PROP += device/qcom/qssi_64/system.prop

TARGET_DISABLE_DASH := true
TARGET_DISABLE_QTI_VPP := true

ifneq ($(TARGET_DISABLE_DASH), true)
    PRODUCT_BOOT_JARS += qcmediaplayer
endif

#Project is missing on sdm845, comment it for now
#ifneq ($(strip $(QCPATH)),)
#    PRODUCT_BOOT_JARS += libprotobuf-java_mls
#endif

PRODUCT_PACKAGES += android.hardware.media.omx@1.0-impl

# Audio configuration file
-include $(TOPDIR)vendor/qcom/opensource/audio-hal/primary-hal/configs/qssi/qssi.mk
-include $(TOPDIR)vendor/qcom/opensource/commonsys/audio/configs/qssi/qssi.mk
AUDIO_FEATURE_ENABLED_SVA_MULTI_STAGE := true
USE_LIB_PROCESS_GROUP := true

PRODUCT_PACKAGES += fs_config_files

ifeq ($(ENABLE_AB), true)
#A/B related packages
PRODUCT_PACKAGES += update_engine \
    update_engine_client \
    update_verifier \
    bootctrl.msmnile \
    android.hardware.boot@1.0-impl \
    android.hardware.boot@1.0-service

PRODUCT_HOST_PACKAGES += \
    brillo_update_payload

#Boot control HAL test app
PRODUCT_PACKAGES_DEBUG += bootctl
endif

#Healthd packages
PRODUCT_PACKAGES += \
    android.hardware.health@1.0-impl \
    android.hardware.health@1.0-convert \
    android.hardware.health@1.0-service \
    libhealthd.msm

DEVICE_FRAMEWORK_MANIFEST_FILE := device/qcom/qssi_64/framework_manifest.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := vendor/qcom/opensource/core-utils/vendor_framework_compatibility_matrix.xml

#audio related module
PRODUCT_PACKAGES += libvolumelistener

# Display/Graphics
PRODUCT_PACKAGES += \
    android.hardware.configstore@1.0-service \
    android.hardware.broadcastradio@1.0-impl

# Camera configuration file. Shared by passthrough/binderized camera HAL
PRODUCT_PACKAGES += camera.device@3.2-impl
PRODUCT_PACKAGES += camera.device@1.0-impl
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-impl
# Enable binderized camera HAL
PRODUCT_PACKAGES += android.hardware.camera.provider@2.4-service_64


# Context hub HAL
PRODUCT_PACKAGES += \
    android.hardware.contexthub@1.0-impl.generic \
    android.hardware.contexthub@1.0-service

# system prop for enabling QFS (QTI Fingerprint Solution)
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.qfp=true

PRODUCT_SYSTEM_PROPERTIES += \
    persist.device_config.runtime_native_boot.iorap_perfetto_enable=true

# USB default HAL
PRODUCT_PACKAGES += \
    android.hardware.usb@1.0-service

#PASR HAL and APP
PRODUCT_PACKAGES += \
    vendor.qti.power.pasrmanager@1.0-service \
    vendor.qti.power.pasrmanager@1.0-impl \
    pasrservice

# Kernel modules install path
KERNEL_MODULES_INSTALL := dlkm
KERNEL_MODULES_OUT := out/target/product/$(PRODUCT_NAME)/$(KERNEL_MODULES_INSTALL)/lib/modules

ifneq ($(strip $(TARGET_BUILD_VARIANT)),user)
PRODUCT_COPY_FILES += \
    device/qcom/qssi_64/init.qcom.testscripts.sh:$(TARGET_COPY_OUT_PRODUCT)/etc/init.qcom.testscripts.sh
endif

PRODUCT_COPY_FILES += \
    device/qcom/qssi_64/public.libraries.product-qti.txt:$(TARGET_COPY_OUT_PRODUCT)/etc/public.libraries-qti.txt

# copy system_ext specific whitelisted libraries to system_ext/etc
PRODUCT_COPY_FILES += \
    device/qcom/qssi_64/public.libraries.system_ext-qti.txt:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/public.libraries-qti.txt

#Enable full treble flag
PRODUCT_FULL_TREBLE_OVERRIDE := true
PRODUCT_VENDOR_MOVE_ENABLED := true
PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE := true

ifneq ($(strip $(TARGET_USES_RRO)),true)
DEVICE_PACKAGE_OVERLAYS += device/qcom/qssi_64/overlay
endif


#Enable vndk-sp Libraries
PRODUCT_PACKAGES += vndk_package

PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE:=true


TARGET_MOUNT_POINTS_SYMLINKS := false

TARGET_USES_MKE2FS := true

PRODUCT_PROPERTY_OVERRIDES += \
ro.crypto.volume.filenames_mode = "aes-256-cts" \
ro.crypto.allow_encrypt_override = true

TARGET_USES_QCOM_DISPLAY_BSP := true

ifeq ($(TARGET_USES_NEW_ION),true)
AUDIO_FEATURE_ENABLED_DLKM := true
else
AUDIO_FEATURE_ENABLED_DLKM := false
endif

# Enable virtual A/B compression
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/vabc_features.mk)
PRODUCT_VIRTUAL_AB_COMPRESSION_METHOD := lz4

# Include mainline components and qssi_64 whitelist
ifeq (true,$(call math_gt_or_eq,$(SHIPPING_API_LEVEL),29))
  $(call inherit-product, device/qcom/qssi_64/qssi_64_whitelist.mk)
  PRODUCT_ARTIFACT_PATH_REQUIREMENT_IGNORE_PATHS := /system/system_ext/
  PRODUCT_ENFORCE_ARTIFACT_PATH_REQUIREMENTS := true
endif

# Enable support for APEX updates
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

#enable virtualization service, please verify if virtualization needs to be updated
#for low ram targets
$(call inherit-product, packages/modules/Virtualization/apex/product_packages.mk)

# Enable allowlist for several aosp packages that should not be scanned in a "stopped" state
# Some CTS test case failed after enabling feature config_stopSystemPackagesByDefault
PRODUCT_PACKAGES += initial-package-stopped-states-aosp.xml

###################################################################################
# This is the End of target.mk file.
# Now, Pickup other split product.mk files:
###################################################################################
$(call inherit-product-if-exists, vendor/qcom/defs/product-defs/system/*.mk)
###################################################################################
