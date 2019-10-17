#!/bin/sh

set -e

KUBE_ROOT=$(dirname "{BASH_SOURCE}")
HTTPD_DEBS_DIR=${KUBE_ROOT}/httpd
REPOS_DIR=${KUBE_ROOT}/repos
HTTPD_DIR=/var/www/html

### 获取本地ip (如果本地有多个网卡，此命令获取IP，就获取出错了)
#HOST_IP=$(ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:")
#echo $HOST_IP


httpd="apr-1.4.8-3.el7_4.1.i686.rpm httpd-2.4.6-80.el7.centos.x86_64.rpm apr-1.4.8-3.el7_4.1.x86_64.rpm httpd-tools-2.4.6-80.el7.centos.x86_64.rpm apr-util-1.5.2-6.el7.i686.rpm mailcap-2.1.41-2.el7.noarch.rpm apr-util-1.5.2-6.el7.x86_64.rpm"

echo "#### Check httpd if exists"
httpd -v || (
echo ""
echo "#### Install httpd"
for deb in ${httpd}
do
  rpm -ivh  "${HTTPD_DEBS_DIR}/${deb}" --nodeps --force
done
)

### 开启httpd服务
systemctl start httpd.service
### 设置httpd自动启动
systemctl enable httpd.service

echo '============================================================'
echo '=================Install httpd success!...=================='
echo '============================================================'

### 开启端口
firewall-cmd --zone=public --add-port=80/tcp --permanent
### 重启防火墙
firewall-cmd --reload


export ProgName=`basename $0`
cd `dirname $0`
export CurrDir=`pwd`
cd - > /dev/null 2>&1

### 将 ISO 放到文件夹: /var/www/html/ 下
[ ! -d ${CurrDir}/repos ] && echo  "Error: ${CurrDir}/repo do not exist" >&2 && exit
cp -rf ${CurrDir}/repos ${HTTPD_DIR}/repos


### check if currect use is root user
CUR_USER=`whoami`
if [ $CUR_USER != 'root' ]
then
      echo 'The operation will modify system files,you should be  root!'
　　exit 1
fi

echo '============================================================'
echo '==================Add caicloud yum repo...=================='
echo '============================================================'
### backup yum repos
(ls -dt /etc/yum.repos.d*|head -n 5; ls -d /etc/yum.repos.d*) | sort | uniq -u | xargs /bin/rm -rf;
    mv /etc/yum.repos.d{,.`date +"%Y-%m-%d-%H-%M-%S"`.bak} ;
    mkdir -p /etc/yum.repos.d

#create local.repo
if [ ! -f "/etc/yum.repos.d/caicloud.repo" ]; then
cat > /etc/yum.repos.d/caicloud.repo <<EOF
[caicloud]
name=caicloud
baseurl=file://${HTTPD_DIR}/repos
gpgcheck=0
enabled=1
EOF
fi
echo '============================================================'
echo '==========Add caicloud yum repo success...=================='
echo '============================================================'

yum clean all
yum makecache
yum repolist all

