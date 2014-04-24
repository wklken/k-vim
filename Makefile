WAF = ./waf
WCFLAG = '' #--env auto #  wscript安装软件有问题，所以暂不能用
CURRENT_DIR = .
YCM_DIR = ${CURRENT_DIR}/bundle/YouCompleteMe/cpp/ycm
CONF_FILE_DIR = ${CURRENT_DIR}/others/YCM-Configure-File
CONF_FILE = _ycm_extra_conf.py
OLD_CONF_FILE = .ycm_extra_conf.py
RM = rm
RFLAG = -rf

three: two
	echo "fix YouCompleteMe cpp/ycm/.ycm_extra_conf.py file"
	echo "use hard link"
	echo "back old file"
	mv ${YCM_DIR}/${OLD_CONF_FILE} ${YCM_DIR}/${CONF_FILE}
	ln ${CONF_FILE_DIR}/${CONF_FILE} ${YCM_DIR}/${OLD_CONF_FILE}

two: one
	sh -x install.sh

one: tmp
	#${WAF} build
	{WAF} do

clean:
	${RM} ${RFLAG} one two build tmp
