#!/usr/bin/env python
#coding: utf-8

import sys
#import os


top = '.'
out = 'build'

def help(ctx):
    print("no help")
    print("you can execute 'python3 waf do'")

def configure(ctx):
    if not sys.platform == 'linux2':
        exit("only Linux")

    ctx.env.ENV = ctx.options.env

    if ctx.env.ENV == 'auto':
        ctx.find_program("aptitude", var="APTITUDE")
        ctx.find_program("pip", var="PIP")
    else:
        ctx.find_program("pyflakes", var="PYFLAKES")
        ctx.find_program("pep8", var="PEP8")
        ctx.find_program("pylint", var="PYLINT")
        ctx.find_program("ctags", var="CTAGS")
        ctx.find_program("vim", var="VIM")
        ctx.find_program("cmake", var="CMAKE")
        ctx.find_program("sh", var="SH")
        ctx.find_program("touch", var="TOUCH")

def options(ctx):
    ctx.add_option('--env', action='store', default='', help='auto instead env')

def build(bld):
    if bld.cmd == 'install':
        pass

    elif bld.env.ENV == 'auto':
        bld(rule = '${APTITUDE} install ${TAG}',
                    target = 'python-${PIP} ${CTAGS} ${VIM} ${VIM}-python ${cmake} build-essential')
        bld(rule = '${PIP} install ${PYFLAKES}')
        bld(rule = '${PIP} install ${PEP8}')
        bld(rule = '${PIP} install ${PYLINT}')
    else:
        pass

    #bld(rule = '${SH} -x ${SRC}', source='install.sh')
    bld(rule = '${TOUCH} {TAG}', target='one')

def do(ctx):
    from waflib import Options

    lst = ['configure', 'build']

    Options.commands = lst + Options.commands
