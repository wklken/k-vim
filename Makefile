WAF = ./waf
WCFLAG = --env auto
CURRENT_DIR = .
YCM_DIR = ${CURRENT_DIR}/bundle/YouCompleteMe/cpp/ycm/
CONF_FILE_DIR = ${CURRENT_DIR}/others/YCM--Configure-File/
CONF_FILE = _ycm_extra_conf.py
OLD_CONF_FILE = .ycm_extra_conf
RM = rm

three: one two
	echo "fix YouCompleteMe cpp/ycm/.ycm_extra_conf.py file"
	echo "use hard link"
	echo "back old file"
	mv ${YCM_DIR}/${OLD_CONF_FILE} ${YCM_DIR}/${CONF_FILE}
	ln ${CONF_FILE_DIR}/${CONF_FILE} ${YCM_DIR}/${OLD_CONF_FILE}
	${RM} one two

two: one nextone
	sh -x install.sh

one:
	${WAF} configure ${WCFLAG}

nextone: one
	${WAF} build
