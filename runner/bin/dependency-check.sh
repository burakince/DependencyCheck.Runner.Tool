#!/bin/sh
#
# Copyright (c) 2012-2013 Jeremy Long.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------


# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

PRGDIR=`dirname "$PRG"`
BASEDIR=`cd "$PRGDIR/.." >/dev/null; pwd`

# Reset the REPO variable. If you need to influence this use the environment setup file.
REPO=


# OS specific support.  $var _must_ be set to either true or false.
cygwin=false;
darwin=false;
case "`uname`" in
  CYGWIN*) cygwin=true ;;
  Darwin*) darwin=true
           if [ -z "$JAVA_VERSION" ] ; then
             JAVA_VERSION="CurrentJDK"
           else
             echo "Using Java version: $JAVA_VERSION"
           fi
		   if [ -z "$JAVA_HOME" ]; then
		      if [ -x "/usr/libexec/java_home" ]; then
			      JAVA_HOME=`/usr/libexec/java_home`
			  else
			      JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/${JAVA_VERSION}/Home
			  fi
           fi       
           ;;
esac

if [ -z "$JAVA_HOME" ] ; then
  if [ -r /etc/gentoo-release ] ; then
    JAVA_HOME=`java-config --jre-home`
  fi
fi

# For Cygwin, ensure paths are in UNIX format before anything is touched
if $cygwin ; then
  [ -n "$JAVA_HOME" ] && JAVA_HOME=`cygpath --unix "$JAVA_HOME"`
  [ -n "$CLASSPATH" ] && CLASSPATH=`cygpath --path --unix "$CLASSPATH"`
fi

# If a specific java binary isn't specified search for the standard 'java' binary
if [ -z "$JAVACMD" ] ; then
  if [ -n "$JAVA_HOME"  ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
      # IBM's JDK on AIX uses strange locations for the executables
      JAVACMD="$JAVA_HOME/jre/sh/java"
    else
      JAVACMD="$JAVA_HOME/bin/java"
    fi
  else
    JAVACMD=`which java`
  fi
fi

if [ ! -x "$JAVACMD" ] ; then
  echo "Error: JAVA_HOME is not defined correctly." 1>&2
  echo "  We cannot execute $JAVACMD" 1>&2
  exit 1
fi

if [ -z "$REPO" ]
then
  REPO="$BASEDIR"/repo
fi

CLASSPATH="$BASEDIR"/plugins/*:"$REPO"/commons-cli/commons-cli/1.4/commons-cli-1.4.jar:"$REPO"/org/owasp/dependency-check-core/3.1.1/dependency-check-core-3.1.1.jar:"$REPO"/com/vdurmont/semver4j/2.1.0/semver4j-2.1.0.jar:"$REPO"/joda-time/joda-time/1.6/joda-time-1.6.jar:"$REPO"/org/apache/commons/commons-compress/1.15/commons-compress-1.15.jar:"$REPO"/org/objenesis/objenesis/2.6/objenesis-2.6.jar:"$REPO"/commons-io/commons-io/2.6/commons-io-2.6.jar:"$REPO"/org/apache/commons/commons-lang3/3.4/commons-lang3-3.4.jar:"$REPO"/org/apache/lucene/lucene-core/5.5.5/lucene-core-5.5.5.jar:"$REPO"/org/apache/lucene/lucene-analyzers-common/5.5.5/lucene-analyzers-common-5.5.5.jar:"$REPO"/org/apache/lucene/lucene-queryparser/5.5.5/lucene-queryparser-5.5.5.jar:"$REPO"/org/apache/lucene/lucene-queries/5.5.5/lucene-queries-5.5.5.jar:"$REPO"/org/apache/lucene/lucene-sandbox/5.5.5/lucene-sandbox-5.5.5.jar:"$REPO"/org/apache/velocity/velocity/1.7/velocity-1.7.jar:"$REPO"/commons-collections/commons-collections/3.2.2/commons-collections-3.2.2.jar:"$REPO"/commons-lang/commons-lang/2.4/commons-lang-2.4.jar:"$REPO"/com/h2database/h2/1.4.196/h2-1.4.196.jar:"$REPO"/org/glassfish/javax.json/1.0.4/javax.json-1.0.4.jar:"$REPO"/org/jsoup/jsoup/1.11.2/jsoup-1.11.2.jar:"$REPO"/com/sun/mail/mailapi/1.6.0/mailapi-1.6.0.jar:"$REPO"/com/google/code/gson/gson/2.8.2/gson-2.8.2.jar:"$REPO"/org/owasp/dependency-check-utils/3.1.1/dependency-check-utils-3.1.1.jar:"$REPO"/org/slf4j/slf4j-api/1.7.25/slf4j-api-1.7.25.jar:"$REPO"/ch/qos/logback/logback-core/1.2.3/logback-core-1.2.3.jar:"$REPO"/ch/qos/logback/logback-classic/1.2.3/logback-classic-1.2.3.jar:"$REPO"/org/apache/ant/ant/1.9.9/ant-1.9.9.jar:"$REPO"/org/owasp/dependency-check-cli/3.1.1/dependency-check-cli-3.1.1.jar

ENDORSED_DIR=
if [ -n "$ENDORSED_DIR" ] ; then
  CLASSPATH=$BASEDIR/$ENDORSED_DIR/*:$CLASSPATH
fi

if [ -n "$CLASSPATH_PREFIX" ] ; then
  CLASSPATH=$CLASSPATH_PREFIX:$CLASSPATH
fi

# For Cygwin, switch paths to Windows format before running java
if $cygwin; then
  [ -n "$CLASSPATH" ] && CLASSPATH=`cygpath --path --windows "$CLASSPATH"`
  [ -n "$JAVA_HOME" ] && JAVA_HOME=`cygpath --path --windows "$JAVA_HOME"`
  [ -n "$HOME" ] && HOME=`cygpath --path --windows "$HOME"`
  [ -n "$BASEDIR" ] && BASEDIR=`cygpath --path --windows "$BASEDIR"`
  [ -n "$REPO" ] && REPO=`cygpath --path --windows "$REPO"`
fi

exec "$JAVACMD" $JAVA_OPTS  \
  -classpath "$CLASSPATH" \
  -Dapp.name="dependency-check" \
  -Dapp.pid="$$" \
  -Dapp.repo="$REPO" \
  -Dapp.home="$BASEDIR" \
  -Dbasedir="$BASEDIR" \
  org.owasp.dependencycheck.App \
  "$@"
