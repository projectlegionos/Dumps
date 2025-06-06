#!/system/bin/sh

platform_id=""
mem_total=""
prjname=`getprop ro.boot.prjname`

function configure_lito_parameters() {
    if [ $mem_total -le 8388608 ]; then
        echo 25 > /proc/sys/vm/watermark_scale_factor
    else
        echo 16 > /proc/sys/vm/watermark_scale_factor
    fi
}

function configure_kona_parameters() {
    if [ $mem_total -le 8388608 ]; then
        echo 25 > /proc/sys/vm/watermark_scale_factor
    else
        echo 16 > /proc/sys/vm/watermark_scale_factor
    fi
}

function configure_lahaina_parameters() {
    if [ $mem_total -le 8388608 ]; then
        echo 25 > /proc/sys/vm/watermark_scale_factor
        case $prjname in
            "21695")
                echo 32 > /proc/sys/vm/watermark_scale_factor
                ;;
        esac
    else
        echo 16 > /proc/sys/vm/watermark_scale_factor
    fi
}

function configure_taro_parameters() {
    if [ $mem_total -le 8388608 ]; then
        echo 25 > /proc/sys/vm/watermark_scale_factor
    else
        echo 16 > /proc/sys/vm/watermark_scale_factor
    fi
}

function configure_holi_parameters() {
    if [ $mem_total -le 8388608 ]; then
        echo 25 > /proc/sys/vm/watermark_scale_factor
    else
        echo 16 > /proc/sys/vm/watermark_scale_factor
    fi
    case $prjname in
        "21707"|"21708"|"216EA"|"2162B"|"22667"|"22668"|"22602")
            echo 0 > /proc/sys/vm/watermark_boost_factor
            ;;
        *)
            echo 15000 > /proc/sys/vm/watermark_boost_factor
            ;;
    esac
}

function configure_bengal_parameters() {
    if [ $mem_total -le 8388608 ]; then
        echo 32 > /proc/sys/vm/watermark_scale_factor
    else
        echo 16 > /proc/sys/vm/watermark_scale_factor
    fi
}

function configure_default_parameters() {
}

function mm_configure() {
    platform_id=`cat /sys/devices/soc0/soc_id`
    mem_total_str=`cat /proc/meminfo | grep MemTotal`
    mem_total=${mem_total_str:16:8}

    if [ -z $mem_total ] || [ -z $platform_id ]
    then
        echo -e "read meminfo failed\n"
        exit -1
    fi

    echo "$platform_id: $mem_total"
    # common configure here
    # disable watermark_boost_factor
    echo 0 > /proc/sys/vm/watermark_boost_factor

    case "$platform_id" in
        "415"|"439"|"456"|"501"|"502"|"475")
            configure_lahaina_parameters
            ;;

        "506")
            #  SM7450
            configure_lahaina_parameters
            ;;

        "457"|"530")
            # SM8450 | SM8475
            configure_taro_parameters
            ;;

        "356")
            # SM8250
            configure_kona_parameters
            ;;

        "400"|"459")
            # SM7250 | SM7225
            configure_lito_parameters
            ;;
        "454" |"507")
            # SM4350 ,SM6375
            configure_holi_parameters
            ;;
        "518")
            # SM6225
            configure_bengal_parameters
            ;;
        *)
            echo -e "***WARNING***: Invalid SoC ID\n"
            configure_default_parameters
            ;;
    esac
}

mm_configure
