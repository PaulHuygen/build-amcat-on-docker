m4_include(inst.m4)m4_dnl
\documentclass[twoside]{artikel3}
\pagestyle{headings}
\usepackage{pdfswitch}
\usepackage{figlatex}
\usepackage{makeidx}
\usepackage{a4wide}
\usepackage{alltt}
\usepackage{color}
\usepackage{lmodern}
\usepackage[british]{babel}
\renewcommand{\indexname}{General index}
\makeindex
\newcommand{\thedoctitle}{m4_doctitle}
\newcommand{\theauthor}{m4_author}
\newcommand{\thesubject}{m4_subject}
\newcommand{\NGINX}{\textsc{nginx}}
\newcommand{\URL}{\textsc{url}}
\newcommand{\UWSGI}{\textsc{uwsgi}}
\title{\thedoctitle}
\author{\theauthor}
\date{m4_docdate}
%
% Commands for frequently used constructions
%
\newcommand{\pdf}{\textsc{pdf}}
\newcommand{\HTML}{\textsc{html}}
\newcommand{\URI}{\textsc{uri}}
%
% PDF-specific settings
%
\ifpdf
% \usepackage[pdftex]{graphicx}       %%% graphics for dvips
% \usepackage[pdftex]{thumbpdf}      %%% thumbnails for ps2pdf
% \usepackage[pdftex]{thumbpdf}      %%% thumbnails for pdflatex
% \usepackage[pdftex,                %%% hyper-references for pdflatex
% bookmarks=true,%                   %%% generate bookmarks ...
% bookmarksnumbered=true,%           %%% ... with numbers
% a4paper=true,%                     %%% that is our papersize.
% hypertexnames=false,%              %%% needed for correct links to figures !!!
% breaklinks=true,%                  %%% break links if exceeding a single line
% linkbordercolor={0 0 1}]{hyperref} %%% blue frames around links
% %                                  %%% pdfborder={0 0 1} is the
% %                                  default
% \hypersetup{
%   pdfauthor   = {\theauthor},
%   pdftitle    = {\thedoctitle},
%   pdfsubject  = {web program},
%  }
 \renewcommand{\NWlink}[2]{\hyperlink{#1}{#2}}
 \renewcommand{\NWtarget}[2]{\hypertarget{#1}{#2}}
 \renewcommand{\NWsep}{$\diamond$\rule[-1\baselineskip]{0pt}{1\baselineskip}}
\else
%\usepackage[dvips]{graphicx}        %%% graphics for dvips
%\usepackage[latex2html,             %%% hyper-references for ps2pdf
%bookmarks=true,%                   %%% generate bookmarks ...
%bookmarksnumbered=true,%           %%% ... with numbers
%hypertexnames=false,%              %%% needed for correct links to figures !!!
%breaklinks=true,%                  %%% breaks lines, but links are very small
%linkbordercolor={0 0 1},%          %%% blue frames around links
%pdfborder={0 0 112.0}]{hyperref}%  %%% border-width of frames 
\usepackage{html}
\renewcommand{\NWlink}[2]{\hyperlink{#1}{#2}}
\renewcommand{\NWtarget}[2]{\hypertarget{#1}{#2}}
\fi
%
% Settings
%
\raggedbottom
\makeatletter
\if@@oldtoc
  \renewcommand\toc@@font[1]{\relax}
\else
  \renewcommand*\toc@@font[1]{%
    \ifcase#1\relax
    \chaptocfont
    \or\slshape
    \or\rmfamily
    \fi}
\fi
\makeatother
\newcommand{\chaptocfont}{\large\bfseries}

\newcommand{\pdfpsinc}[2]{%
\ifpdf
  \input{#1}
\else
  \input{#2}
\fi
}
\begin{document}
\maketitle
\begin{abstract}
  Dockerfile to generate a Docker container with Amcat in it.
  Contains the following elements: 1) Amcat; 2) Postgresql; 3) ElasticSearch; 4) \UWSGI{}; 5) \NGINX{}; 6) Supervisord.
\end{abstract}
\tableofcontents

\section{Introduction}
\label{sec:Introduction}

This package builds a Docker Container that runs Amcat (version
m4_amcatversion). The product is a single container that contains all
the elements needed for Amcat, i.e. 1) Amcat itself; 2) Postgresql
database and Elastic search; 3) \UWSGI{} and \NGINX{}. The container
is based on a Docker Image that contains Ubuntu version 14.04. Ubuntu
does not support Upstart, therefore, Supervisor is used instead, as
described in \href{m4_django_uwsgi_nginx_repo}{this repo}.

\section{The program}
\label{sec:program}

The system executes the following steps:

\begin{enumerate}
\item Start a new Docker-container based on Ubuntu m4_ubuntuversion.
\item Upload an installation script to it, that installs and configures the software
  elements.
\item Run the installation script.
\item Start the supervisor daemon
\end{enumerate}

The installation script installs/configures the following elements:

\begin{enumerate}
\item Amcat itself.
\item Databases: Postgresql and ElasticSearch.
\item Java (needed by ElasticSearch).
\item \UWSGI{} and \NGINX{}
\item Supervisord
\end{enumerate}


\subsection{Docker build file}
\label{sec:dockerbuild}

The set-up has been stolen from the
\href{m4_django_uwsgi_nginx_repo}{\texttt{django-uwsgi-nginx}} Github repo.

@o buildenv/Dockerfile @{@%
FROM ubuntu:m4_ubuntuversion

MAINTAINER PaulHuygen

# Install required packages and remove the apt packages cache when done.

@< copy the stuff that is needed @>
@< run the installation script @>
@< start supervisord in Dockerfile @>

@% RUN apt-get update && apt-get install -y \
@% 	git \
@% 	python \
@% 	python-dev \
@% 	python-setuptools \
@% 	nginx \
@% 	supervisor \
@% 	sqlite3 \
@%   && rm -rf /var/lib/apt/lists/*
@% 
@% RUN easy_install pip
@% 
@% # install uwsgi now because it takes a little while
@% RUN pip install uwsgi
@% 
@% # setup all the configfiles
@% RUN echo "daemon off;" >> /etc/nginx/nginx.conf
@% COPY nginx-app.conf /etc/nginx/sites-available/default
@% COPY supervisor-app.conf /etc/supervisor/conf.d/
@% 
@% # COPY requirements.txt and RUN pip install BEFORE adding the rest of your code, this will cause Docker's caching mechanism
@% # to prevent re-installinig (all your) dependencies when you made a change a line or two in your app. 
@% 
@% COPY app/requirements.txt /home/docker/code/app/
@% RUN pip install -r /home/docker/code/app/requirements.txt
@% 
@% # add (the rest of) our code
@% COPY . /home/docker/code/
@% 
@% # install django, normally you would remove this step because your project would already
@% # be installed in the code/app/ directory
@% RUN django-admin.py startproject website /home/docker/code/app/ 
@% 
@% 
@% EXPOSE 80
@% CMD ["supervisord", "-n"]

@| @}

\subsection{The installation script}
\label{sec:installscript}

@d run the installation script @{@%
RUN /root/installationscript
@| @}


@o buildenv/installationscript @{@%
#!/bin/bash
@< find out script location @>
cd $SCRIPTDIR
@< prepare ubuntu @>
@< install/configure the elements @>
@| @}

To start with, find out the location of the installation-script. That
is the place where we will store all other material that we need for
the installation. 

@d find out script location @{@%
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OLDD=`pwd`
@| SCRIPTDIR OLDD @}

Th installation script expects everything that it needs to be in the
same directory. So, let us copy everything to this place.

@d copy the stuff that is needed @{@%
COPY . /root/
@| @}



\subsection{Prepare the operating system}
\label{sec:installscript}

The new container will be built on top of an Ubuntu image. Make this
image fit for the installation of Amcat, that database services and
the web-services. The \verb|root| will perform the installation and
everything that is needed will be copied to the \verb|/root| directory
of the image.


\subsubsection{HTTPS protocol for APT}
\label{sec:https}

A slight complication is the R package. We need a more recent version of
R than Ubuntu m4_ubuntuversion supplies. When I developed this system,
I could only install the latest R from a Cran mirror that used the
\verb|https| protocol. To use that protocol in \verb|apt|, package
\verb| apt-transport-https| has to be installed. If the
\verb|apt|-sources list contains the \url{} of a repo that uses this
protocol while \verb|apt-transport-https| has not yet been installed,
\verb|apt| does not work. Therefore, we will first install \verb|apt-transport-https|.

@d prepare ubuntu @{@%
apt-get update && apt-get -y upgrade 
apt-get -y install apt-transport-https 
@| @}

\subsubsection{R repo}
\label{sec:R}

Include R-cran mirrors to the list of repo's from which \verb|apt|
downloads packages. Supply the key.

@d prepare ubuntu @{@%
echo 'deb https://mirrors.cicku.me/CRAN/bin/linux/ubuntu trusty/' > /etc/apt/sources.list.d/r-cran-trusty.list
echo 'deb https://cran.rstudio.com/bin/linux/ubuntu trusty/' >> /etc/apt/sources.list.d/r-cran-trusty.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys m4_apt_key
apt-get update && apt-get -y upgrade 
@| @}

\subsubsection{Install ubuntu packages}
\label{sec:install-packages}

Let us make a list of the Ubuntu packages that need to be
installed. Put the list in a file and give that that file to
\verb|apt-get|. Some of the items in the list are copied form a
similar list in the Amcat distribution.
Todo: explain why these packages are needed.

@o buildenv/apt_requirements @{@%
antiword
git
graphviz
lib32z1-dev
libxml2-dev
libxslt-dev
nginx
nodejs-legacy
npm
postgresql
postgresql-contrib-9.3
postgresql-server-dev-9.3
python-dev
python-pdfminer
python-pip
python-software-properties
python-virtualenv
r-base
r-base-dev
rabbitmq-server
wget
software-properties-common
supervisor
unrtf 
@| @}

@d prepare ubuntu @{@%
cat apt_requirements.txt | tr '\n' ' ' | xargs apt-get install -y
@| @}

\subsubsection{Java}
\label{sec:java}

It seems that Oracle Java 1.8 is needed for ElasticSearch. Oracle Java
cannot be obtained from its original repository without human
intervention. Therefore you, gentle reader, have to obtain the tarball
beforehand and put it in \verb|buildenv| before building the container. 

@d install/configure the elements @{@%
@< install java @>
@| @}

@d install java @{@%
cd /usr/local/share
tar -xzf $SCRIPTDIR/m4_javatarball
@| @}

Make this java findable: set variable \verb|JAVA_HOME| and put the
executables somewhere in the path.

@d install java @{@%
export JAVA_HOME=/usr/local/share/m4_javabasename
echo "export JAVA_HOME=/usr/local/share/m4_javabasename" >> /etc/profile
for file in $JAVA_HOME/bin/* ; do ln -s $file /usr/local/bin/ ; done 
@| @}

\subsection{Databases}
\label{sec:databases}

Amacat needs Postgresql and ElasticSearch. Postgresql has been
provided by Ubuntu and it is started by SystemV. Elasticsearch is obtained
from \url{elasticsearch.org}. First, generate a database for Amcat in
Postgresql.

@d install/configure the elements @{@%
service postgresql start
sudo -u postgres createuser -s m4_db_user
createdb amcat
@| @}

Install ElasticSearch.

@d install/configure the elements @{@%
cd /tmp
wget "m4_elastic_url"
dpkg -i m4_elastic_deb
rm m4_elastic_deb
@| @}

Install Elastic plug-ins

@d install/configure the elements @{@%
/usr/share/elasticsearch/bin/plugin -install elasticsearch/elasticsearch-analysis-icu/2.4.2
/usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head
/usr/share/elasticsearch/bin/plugin -install lukas-vlcek/bigdesk
echo -e "\nscript.disable_dynamic: false" | tee -a /etc/elasticsearch/elasticsearch.yml
@| @}

Tell ElasticSearch where it can find Java:

@d install/configure the elements @{@%
echo -e "\nscript.disable_dynamic: false" | tee -a /etc/elasticsearch/elasticsearch.yml
@| @}

Install Hitcount:

@d install/configure the elements @{@%
wget m4_hitcountjar_url -O /usr/share/elasticsearch/hitcount.jar
@| @}

Tell ElasticSearch about hitcount. Modify \verb|/etc/init.d/elasticsearch|:

@d install/configure the elements @{@%
sed </etc/init.d/elasticsearch '/ES_HOME=/a\ES_CLASSPATH=$ES_HOME/hitcount.jar' >/tmp/es1
sed </tmp/es1 '/ES_CLASSPATH=/a\export ES_CLASSPATH' >/tmp/es2
sed </tmp/es2 '/DAEMON_OPTS=/s/\"$/ -Des.index.similarity.default.type=nl.vu.amcat.HitCountSimilarityProvider\"/' >/etc/init.d/elasticsearch
rm /tmp/es1 /tmp/es2
@| @}

When the plug-ins have been installed, re-start elastic:

@d install/configure the elements @{@%
service elasticsearch restart
@| @}

\subsection{Web-service}
\label{sec:webservice}

Present Amcat on the web. It is straightforward to use uwsgi for
the amcat-app. Although theoretically uwsgi would be sufficient to
present the Amcat app on the web, we will wrap uwsgi into
\verb|nginx|. 

We cannot use upstart in Docker, so we will use \verb|supervisor| to
run uwsgi. To this end, we will generate an executable script that can
be run by supervisor.

\subsubsection{uwsgi}
\label{sec:uwsgi}

@o buildenv/uwsgi_amcat @{@%
#!/bin/bash
@% export AMCATROOT=/usr/local/share/amcat
@% export AMCATUSER=root
@% export AMCATGROUP=root
@% export DJANGO_DB_HOST=localhost
@% export DJANGO_DB_USER=root
@% export DJANGO_DB_PASSWORD=amcat
@% export DJANGO_DB_NAME=amcat
@% export DJANGO_DEBUG=N
@% 
@% export DJANGO_RAVEN_DSN="http://03f75de857df4e2b8518da24b8a0317d:7600de01fd704c5fac1472074aa0766d@sentry.vanatteveldt.com/4"
@% export AMCAT_SERVER_STATUS=production
@% 
@% export PYTHONPATH=/usr/local/share/amcat
@% 
@% export UWSGI_SOCKET=/tmp/amcat.socket
@% export UWSGI_MAX_REQUESTS=50
@% export UWSGI_BUFFER_SIZE=8192
@% 
/usr/local/bin/uwsgi \
     --logto m4_uwsgi_logfile \
     --socket m4_uwsgi_socket \
     --chmod --uid m4_amcat_user --gid m4_amcat_group \
     --chdir m4_amcat_root  \
     --processes 4 \
     --master \
     --wsgi-file navigator/wsgi.py

@| @}

Move the script to a suitable place in the filesystem of the
container.

@d install/configure the elements @{@%
mv /root/uwsgi_amcat /usr/local/bin
chmod 775 /usr/local/bin/uwsgi_amcat
@| @}

\subsubsection{NGINX}
\label{sec:NGINX}

\textsc{Nginx} has been installed by
\textsc{apt-get}. Starting/stopping is controlled by SystemV. We have to
replace the default site-configuration file by a special
configuration file for Amcat:

@o buildenv/nginx_amcat.conf @{@%
server {
    listen 80;
    server_name localhost;
    keepalive_timeout   70;

    location /media/ {
      alias m4_amcat_root`'/navigator/;
    }

    location / {
        include uwsgi_params;
        uwsgi_pass unix:<!!>m4_uwsgi_socket<!!>;
        uwsgi_read_timeout 600000;
        uwsgi_send_timeout 600000;
        send_timeout 60000;
        client_max_body_size 0;
    }

    location /nginx_status {
            stub_status on;
            access_log   off;
        }
}

@| @}

@d install/configure the elements @{@%
rm -rf /etc/nginx/sites-enabled/default
cp /root/nginx_amcat.conf /etc/nginx/sites_available/amcat.conf
ln -s /etc/nginx/sites_available/amcat.conf /etc/nginx/sites_enabled/amcat.conf
service nginx restart
@| @}


\subsection{Celery}
\label{sec:celery}

\href{m4_celery_website}{Celery} is a ``Distributed Task Queue'',
implemented in Python. Amcat uses celery to delegate tasks like
annotation to workers. 

Install Celery and provide an executable script that can be run by
Supervisord.

@o buildenv/amcat-celery @{@%
#!/bin/bash
export AMCATROOT=m4_amcat_root
export AMCATUSER=m4_amcat_user
export AMCATGROUP=m4_amcat_user
export DJANGO_DB_HOST=localhost
export DJANGO_DB_USER=m4_amcat_db_user
export DJANGO_DB_PASSWORD=m4_amcat_db_password
export DJANGO_DB_NAME=m4_amcat_db_name
export DJANGO_DEBUG=N

export AMCAT_SERVER_STATUS=production

export PYTHONPATH=m4_amcat_root

export DJANGO_SETTINGS_MODULE=settings

celery -A amcat.amcatcelery worker -l info -Q amcat > m4_celery_logfile 2>&1

@| @}



@d install/configure the elements @{@%
pip install celery
mv /root/amcat_celery /usr/local/bin/
chmod 775 /usr/local/bin/amcat_celery
@| @}


\subsection{Amcat itself}
\label{sec:Amcat}

Download and compile Amcat. To compile amcat we need Bower, so we
install that first.

@d install/configure the elements @{@%
npm install -g bower
@| @}

Download Amcat in \texttt{m4_amcatsocket} and compile:

@d install/configure the elements @{@%
cd m4_amcatsocket
git clone -b m4_amcat_gitbranche m4_amcat_remote_repo
cd m4_amcat_root
pip install -r requirements.txt
export PYTHONPATH=$PYTHONPATH:m4_amcat_root
export AMCAT_ES_LEGACY_HASH=N
echo "export PYTHONPATH=$PYTHONPATH:m4_amcat_root" >> /etc/profile.d/amcat
echo 'export AMCAT_ES_LEGACY_HASH=N' >> /etc/profile.d/amcat
bower --allow-root install
python -m amcat.manage syncdb

@| @}




\subsection{Supervisord}
\label{sec:supervisord}

As said before, we cannot use Upstart to control daemons, therefore we
use the Supervisor package that we have installed with
\verb|apt-get|. We will use supervisor to control amcat-uwsgi and
celery. We do not use it for nginx, postgresql or elastic because they
are already controlled by SystemV.

Generate a configuration-file for supervisor.It starts the scrips to
run Amcat/uwsgi and celery that we have already written.

@o buildenv/supervisor-app.conf @{@%
[program:app-uwsgi]
command = /usr/local/bin/amcat_wsgi

[program:app-celery]
command = /usr/local/bin/amcat_celery

@| @}


@d install/configure the elements @{@%
mv /root/supervisor-app.conf /etc/supervisor/conf.d/
@| @}


Finally, start supervisor. It seems best to do this in the Docker
buildfile:

@d start supervisord in Dockerfile @{@%
EXPOSE 80
CMD ["supervisord", "-n"]
@| @}
 



\appendix

\section{How to read and translate this document}
\label{sec:translatedoc}

This document is an example of \emph{literate
  programming}~\cite{Knuth:1983:LP}. It contains the code of all sorts
of scripts and programs, combined with explaining texts. In this
document the literate programming tool \texttt{nuweb} is used, that is
currently available from Sourceforge
(URL:\url{m4_nuwebURL}). The advantages of Nuweb are, that
it can be used for every programming language and scripting language, that
it can contain multiple program sources and that it is very simple.


\subsection{Read this document}
\label{sec:read}

The document contains \emph{code scraps} that are collected into
output files. An output file (e.g. \texttt{output.fil}) shows up in the text as follows:

\begin{alltt}
"output.fil" \textrm{4a \(\equiv\)}
      # output.fil
      \textrm{\(<\) a macro 4b \(>\)}
      \textrm{\(<\) another macro 4c \(>\)}
      \(\diamond\)

\end{alltt}

The above construction contains text for the file. It is labelled with
a code (in this case 4a)  The constructions between the \(<\) and
\(>\) brackets are macro's, placeholders for texts that can be found
in other places of the document. The test for a macro is found in
constructions that look like:

\begin{alltt}
\textrm{\(<\) a macro 4b \(>\) \(\equiv\)}
     This is a scrap of code inside the macro.
     It is concatenated with other scraps inside the
     macro. The concatenated scraps replace
     the invocation of the macro.

{\footnotesize\textrm Macro defined by 4b, 87e}
{\footnotesize\textrm Macro referenced in 4a}
\end{alltt}

Macro's can be defined on different places. They can contain other macro´s.

\begin{alltt}
\textrm{\(<\) a scrap 87e \(>\) \(\equiv\)}
     This is another scrap in the macro. It is
     concatenated to the text of scrap 4b.
     This scrap contains another macro:
     \textrm{\(<\) another macro 45b \(>\)}

{\footnotesize\textrm Macro defined by 4b, 87e}
{\footnotesize\textrm Macro referenced in 4a}
\end{alltt}


\subsection{Process the document}
\label{sec:processing}

The raw document is named
\verb|a_<!!>m4_progname<!!>.w|. Figure~\ref{fig:fileschema}
\begin{figure}[hbtp]
  \centering
  \includegraphics{fileschema.fig}
  \caption{Translation of the raw code of this document into
    printable/viewable documents and into program sources. The figure
    shows the pathways and the main files involved.}
  \label{fig:fileschema}
\end{figure}
 shows pathways to
translate it into printable/viewable documents and to extract the
program sources. Table~\ref{tab:transtools}
\begin{table}[hbtp]
  \centering
  \begin{tabular}{lll}
    \textbf{Tool} & \textbf{Source} & \textbf{Description} \\
    gawk  & \url{www.gnu.org/software/gawk/}& text-processing scripting language \\
    M4    & \url{www.gnu.org/software/m4/}& Gnu macro processor \\
    nuweb & \url{nuweb.sourceforge.net} & Literate programming tool \\
    tex   & \url{www.ctan.org} & Typesetting system \\
    tex4ht & \url{www.ctan.org} & Convert \TeX{} documents into \texttt{xml}/\texttt{html}
  \end{tabular}
  \caption{Tools to translate this document into readable code and to
    extract the program sources}
  \label{tab:transtools}
\end{table}
lists the tools that are
needed for a translation. Most of the tools (except Nuweb) are available on a
well-equipped Linux system.

@%\textbf{NOTE:} Currently, not the most recent version  of Nuweb is used, but an older version that has been modified by me, Paul Huygen.

@d parameters in Makefile @{@%
NUWEB=m4_nuwebbinary
@| @}


\subsection{Translate and run}
\label{sec:transrun}

This chapter assembles the Makefile for this project.

@o Makefile -t @{@%
@< default target @>

@< parameters in Makefile @> 

@< impliciete make regels @>
@< expliciete make regels @>
@< make targets @>
@| @}

The default target of make is \verb|all|.

@d  default target @{@%
all : @< all targets @>
.PHONY : all

@|PHONY all @}


One of the targets is certainly the \textsc{pdf} version of this
document.

@d all targets @{m4_progname.pdf@}

We use many suffixes that were not known by the C-programmers who
constructed the \texttt{make} utility. Add these suffixes to the list.

@d parameters in Makefile @{@%
.SUFFIXES: .pdf .w .tex .html .aux .log .php

@| SUFFIXES @}



\subsection{Pre-processing}
\label{sec:pre-processing}

To make usable things from the raw input \verb|a_<!!>m4_progname<!!>.w|, do the following:

\begin{enumerate}
\item Process \verb|\$| characters.
\item Run the m4 pre-processor.
\item Run nuweb.
\end{enumerate}

This results in a \LaTeX{} file, that can be converted into a \pdf{}
or a \HTML{} document, and in the program sources and scripts.

\subsubsection{Process `dollar' characters }
\label{sec:procdollars}

Many ``intelligent'' \TeX{} editors (e.g.\ the auctex utility of
Emacs) handle \verb|\$| characters as special, to switch into
mathematics mode. This is irritating in program texts, that often
contain \verb|\$| characters as well. Therefore, we make a stub, that
translates the two-character sequence \verb|\\$| into the single
\verb|\$| character.


@d expliciete make regels @{@%
m4_<!!>m4_progname<!!>.w : a_<!!>m4_progname<!!>.w
@%	gawk '/^@@%/ {next}; {gsub(/[\\][\\$\$]/, "$$");print}' a_<!!>m4_progname<!!>.w > m4_<!!>m4_progname<!!>.w
	gawk '{if(match($$0, "@@<!!>%")) {printf("%s", substr($$0,1,RSTART-1))} else print}' a_<!!>m4_progname.w \
          | gawk '{gsub(/[\\][\\$\$]/, "$$");print}'  > m4_<!!>m4_progname<!!>.w
@% $

@| @}

@%@d expliciete make regels @{@%
@%m4_<!!>m4_progname<!!>.w : a_<!!>m4_progname<!!>.w
@%	gawk '/^@@%/ {next}; {gsub(/[\\][\\$\$]/, "$$");print}' a_<!!>m4_progname<!!>.w > m4_<!!>m4_progname<!!>.w
@%
@%@% $
@%@| @}

\subsubsection{Run the M4 pre-processor}
\label{sec:run_M4}

@d  expliciete make regels @{@%
m4_progname<!!>.w : m4_<!!>m4_progname<!!>.w
	m4 -P m4_<!!>m4_progname<!!>.w > m4_progname<!!>.w

@| @}


\subsection{Typeset this document}
\label{sec:typeset}

Enable the following:
\begin{enumerate}
\item Create a \pdf{} document.
\item Print the typeset document.
\item View the typeset document with a viewer.
\item Create a \HTML document.
\end{enumerate}

In the three items, a typeset \pdf{} document is required or it is the
requirement itself.




\subsubsection{Figures}
\label{sec:figures}

This document contains figures that have been made by
\texttt{xfig}. Post-process the figures to enable inclusion in this
document.

The list of figures to be included:

@d parameters in Makefile @{@%
FIGFILES=fileschema

@| FIGFILES @}

We use the package \texttt{figlatex} to include the pictures. This
package expects two files with extensions \verb|.pdftex| and
\verb|.pdftex_t| for \texttt{pdflatex} and two files with extensions \verb|.pstex| and
\verb|.pstex_t| for the \texttt{latex}/\texttt{dvips}
combination. Probably tex4ht uses the latter two formats too.

Make lists of the graphical files that have to be present for
latex/pdflatex:

@d parameters in Makefile @{@%
FIGFILENAMES=\$(foreach fil,\$(FIGFILES), \$(fil).fig)
PDFT_NAMES=\$(foreach fil,\$(FIGFILES), \$(fil).pdftex_t)
PDF_FIG_NAMES=\$(foreach fil,\$(FIGFILES), \$(fil).pdftex)
PST_NAMES=\$(foreach fil,\$(FIGFILES), \$(fil).pstex_t)
PS_FIG_NAMES=\$(foreach fil,\$(FIGFILES), \$(fil).pstex)

@|FIGFILENAMES PDFT_NAMES PDF_FIG_NAMES PST_NAMES PS_FIG_NAMES@}


Create
the graph files with program \verb|fig2dev|:

@d impliciete make regels @{@%
%.eps: %.fig
	fig2dev -L eps \$< > \$@@

%.pstex: %.fig
	fig2dev -L pstex \$< > \$@@

.PRECIOUS : %.pstex
%.pstex_t: %.fig %.pstex
	fig2dev -L pstex_t -p \$*.pstex \$< > \$@@

%.pdftex: %.fig
	fig2dev -L pdftex \$< > \$@@

.PRECIOUS : %.pdftex
%.pdftex_t: %.fig %.pstex
	fig2dev -L pdftex_t -p \$*.pdftex \$< > \$@@

@| fig2dev @}


\subsubsection{Bibliography}
\label{sec:bbliography}

To keep this document portable, create a portable bibliography
file. It works as follows: This document refers in the
\texttt|bibliography| statement to the local \verb|bib|-file
\verb|m4_progname.bib|. To create this file, copy the auxiliary file
to another file \verb|auxfil.aux|, but replace the argument of the
command \verb|\bibdata{m4_progname}| to the names of the bibliography
files that contain the actual references (they should exist on the
computer on which you try this). This procedure should only be
performed on the computer of the author. Therefore, it is dependent of
a binary file on his computer.


@d expliciete make regels @{@%
bibfile : m4_progname.aux m4_mkportbib
	m4_mkportbib m4_progname m4_bibliographies

.PHONY : bibfile
@| @}

\subsubsection{Create a printable/viewable document}
\label{sec:createpdf}

Make a \pdf{} document for printing and viewing.

@d make targets @{@%
pdf : m4_progname.pdf

print : m4_progname.pdf
	m4_printpdf(m4_progname)

view : m4_progname.pdf
	m4_viewpdf(m4_progname)

@| pdf view print @}

Create the \pdf{} document. This may involve multiple runs of nuweb,
the \LaTeX{} processor and the bib\TeX{} processor, and depends on the
state of the \verb|aux| file that the \LaTeX{} processor creates as a
by-product. Therefore, this is performed in a separate script,
\verb|w2pdf|.

\paragraph{The w2pdf script}
\label{sec:w2pdf}

The three processors nuweb, \LaTeX{} and bib\TeX{} are
intertwined. \LaTeX{} and bib\TeX{} create parameters or change the
value of parameters, and write them in an auxiliary file. The other
processors may need those values to produce the correct output. The
\LaTeX{} processor may even need the parameters in a second
run. Therefore, consider the creation of the (\pdf) document finished
when none of the processors causes the auxiliary file to change. This
is performed by a shell script \verb|w2pdf|.

@%@d make targets @{@%
@%m4_progname.pdf : m4_progname.w \$(FIGFILES)
@%	chmod 775 bin/w2pdf
@%	bin/w2pdf m4_progname
@%
@%@| @}



Note, that in the following \texttt{make} construct, the implicit rule
\verb|.w.pdf| is not used. It turned out, that make did not calculate
the dependencies correctly when I did use this rule.

@d  impliciete make regels@{@%
@%.w.pdf :
%.pdf : %.w \$(W2PDF)  \$(PDF_FIG_NAMES) \$(PDFT_NAMES)
	chmod 775 \$(W2PDF)
	\$(W2PDF) \$*

@| @}

The following is an ugly fix of an unsolved problem. Currently I
develop this thing, while it resides on a remote computer that is
connected via the \verb|sshfs| filesystem. On my home computer I
cannot run executables on this system, but on my work-computer I
can. Therefore, place the following script on a local directory.

@d parameters in Makefile @{@%
W2PDF=w2pdf
@| @}

@d directories to create @{m4_nuwebbindir @| @}

@d expliciete make regels  @{@%
\$(W2PDF) : m4_progname.w
	\$(NUWEB) m4_progname.w
@| @}

m4_dnl
m4_dnl Open compile file.
m4_dnl args: 1) directory; 2) file; 3) Latex compiler
m4_dnl
m4_define(m4_opencompilfil,
<!@o !>\$1<!!>\$2<! @{@%
#!/bin/bash
# !>\$2<! -- compile a nuweb file
# usage: !>\$2<! [filename]
# !>m4_header<!
NUWEB=m4_nuwebbinary
LATEXCOMPILER=!>\$3<!
@< filenames in nuweb compile script @>
@< compile nuweb @>

@| @}
!>)m4_dnl

m4_opencompilfil(<!./!>,<!w2pdf!>,<!pdflatex!>)m4_dnl

@%@o w2pdf @{@%
@%#!/bin/bash
@%# w2pdf -- make a pdf file from a nuweb file
@%# usage: w2pdf [filename]
@%#  [filename]: Name of the nuweb source file.
@%`#' m4_header
@%echo "translate " \$1 >w2pdf.log
@%@< filenames in w2pdf @>
@%
@%@< perform the task of w2pdf @>
@%
@%@| @}

The script retains a copy of the latest version of the auxiliary file.
Then it runs the four processors nuweb, \LaTeX{}, MakeIndex and bib\TeX{}, until
they do not change the auxiliary file or the index. 

@d compile nuweb @{@%
NUWEB=m4_nuweb
@< run the processors until the aux file remains unchanged @>
@< remove the copy of the aux file @>
@| @}

The user provides the name of the nuweb file as argument. Strip the
extension (e.g.\ \verb|.w|) from the filename and create the names of
the \LaTeX{} file (ends with \verb|.tex|), the auxiliary file (ends
with \verb|.aux|) and the copy of the auxiliary file (add \verb|old.|
as a prefix to the auxiliary filename).

@d filenames in nuweb compile script @{@%
nufil=\$1
trunk=\${1%%.*}
texfil=\${trunk}.tex
auxfil=\${trunk}.aux
oldaux=old.\${trunk}.aux
indexfil=\${trunk}.idx
oldindexfil=old.\${trunk}.idx
@| nufil trunk texfil auxfil oldaux indexfil oldindexfil @}

Remove the old copy if it is no longer needed.
@d remove the copy of the aux file @{@%
rm \$oldaux
@| @}

Run the three processors. Do not use the option \verb|-o| (to suppres
generation of program sources) for nuweb,  because \verb|w2pdf| must
be kept up to date as well.

@d run the three processors @{@%
\$NUWEB \$nufil
\$LATEXCOMPILER \$texfil
makeindex \$trunk
bibtex \$trunk
@| nuweb makeindex bibtex @}


Repeat to copy the auxiliary file and the index file  and run the processors until the
auxiliary file and the index file are equal to their copies.
 However, since I have not yet been able to test the \verb|aux|
file and the \verb|idx| in the same test statement, currently only the
\verb|aux| file is tested.

It turns out, that sometimes a strange loop occurs in which the
\verb|aux| file will keep to change. Therefore, with a counter we
prevent the loop to occur more than m4_maxtexloops times.

@d run the processors until the aux file remains unchanged @{@%
LOOPCOUNTER=0
while
  ! cmp -s \$auxfil \$oldaux 
do
  if [ -e \$auxfil ]
  then
   cp \$auxfil \$oldaux
  fi
  if [ -e \$indexfil ]
  then
   cp \$indexfil \$oldindexfil
  fi
  @< run the three processors @>
  if [ \$LOOPCOUNTER -ge 10 ]
  then
    cp \$auxfil \$oldaux
  fi;
done
@| @}


\subsubsection{Create HTML files}
\label{sec:createhtml}

\textsc{Html} is easier to read on-line than a \pdf{} document that
was made for printing. We use \verb|tex4ht| to generate \HTML{}
code. An advantage of this system is, that we can include figures
in the same way as we do for \verb|pdflatex|.

Nuweb creates a \LaTeX{} file that is suitable
for \verb|latex2html| if the source file has \verb|.hw| as suffix instead of
\verb|.w|. However, this feature is not compatible with tex4ht.

Make html file:

@d make targets @{@%
html : m4_htmltarget

@| @}

The \HTML{} file depends on its source file and the graphics files.

Make lists of the graphics files and copy them.

@d parameters in Makefile @{@%
HTML_PS_FIG_NAMES=\$(foreach fil,\$(FIGFILES), m4_htmldocdir/\$(fil).pstex)
HTML_PST_NAMES=\$(foreach fil,\$(FIGFILES), m4_htmldocdir/\$(fil).pstex_t)
@| @}


@d impliciete make regels @{@%
m4_htmldocdir/%.pstex : %.pstex
	cp  \$< \$@@

m4_htmldocdir/%.pstex_t : %.pstex_t
	cp  \$< \$@@

@| @}

Copy the nuweb file into the html directory.

@d expliciete make regels @{@%
m4_htmlsource : m4_progname.w
	cp  m4_progname.w m4_htmlsource

@| @}

We also need a file with the same name as the documentstyle and suffix
\verb|.4ht|. Just copy the file \verb|report.4ht| from the tex4ht
distribution. Currently this seems to work.

@d expliciete make regels @{@%
m4_4htfildest : m4_4htfilsource
	cp m4_4htfilsource m4_4htfildest

@| @}

Copy the bibliography.

@d expliciete make regels  @{@%
m4_htmlbibfil : m4_anuwebdir/m4_progname.bib
	cp m4_anuwebdir/m4_progname.bib m4_htmlbibfil

@| @}



Make a dvi file with \texttt{w2html} and then run
\texttt{htlatex}. 

@d expliciete make regels @{@%
m4_htmltarget : m4_htmlsource m4_4htfildest \$(HTML_PS_FIG_NAMES) \$(HTML_PST_NAMES) m4_htmlbibfil
	cp w2html m4_abindir
	cd m4_abindir && chmod 775 w2html
	cd m4_htmldocdir && m4_abindir/w2html m4_progname.w

@| @}

Create a script that performs the translation.

@%m4_<!!>opencompilfil(m4_htmldocdir/,`w2dvi',`latex')m4_dnl


@o w2html @{@%
#!/bin/bash
# w2html -- make a html file from a nuweb file
# usage: w2html [filename]
#  [filename]: Name of the nuweb source file.
`#' m4_header
echo "translate " \$1 >w2html.log
NUWEB=m4_nuwebbinary
@< filenames in w2html @>

@< perform the task of w2html @>

@| @}

The script is very much like the \verb|w2pdf| script, but at this
moment I have still difficulties to compile the source smoothly into
\textsc{html} and that is why I make a separate file and do not
recycle parts from the other file. However, the file works similar.


@d perform the task of w2html @{@%
@< run the html processors until the aux file remains unchanged @>
@< remove the copy of the aux file @>
@| @}


The user provides the name of the nuweb file as argument. Strip the
extension (e.g.\ \verb|.w|) from the filename and create the names of
the \LaTeX{} file (ends with \verb|.tex|), the auxiliary file (ends
with \verb|.aux|) and the copy of the auxiliary file (add \verb|old.|
as a prefix to the auxiliary filename).

@d filenames in w2html @{@%
nufil=\$1
trunk=\${1%%.*}
texfil=\${trunk}.tex
auxfil=\${trunk}.aux
oldaux=old.\${trunk}.aux
indexfil=\${trunk}.idx
oldindexfil=old.\${trunk}.idx
@| nufil trunk texfil auxfil oldaux @}

@d run the html processors until the aux file remains unchanged @{@%
while
  ! cmp -s \$auxfil \$oldaux 
do
  if [ -e \$auxfil ]
  then
   cp \$auxfil \$oldaux
  fi
@%  if [ -e \$indexfil ]
@%  then
@%   cp \$indexfil \$oldindexfil
@%  fi
  @< run the html processors @>
done
@< run tex4ht @>

@| @}


To work for \textsc{html}, nuweb \emph{must} be run with the \verb|-n|
option, because there are no page numbers.

@d run the html processors @{@%
\$NUWEB -o -n \$nufil
latex \$texfil
makeindex \$trunk
bibtex \$trunk
htlatex \$trunk
@| @}


When the compilation has been satisfied, run makeindex in a special
way, run bibtex again (I don't know why this is necessary) and then run htlatex another time.
@d run tex4ht @{@%
m4_index4ht
makeindex -o \$trunk.ind \$trunk.4dx
bibtex \$trunk
htlatex \$trunk
@| @}


\paragraph{create the program sources}
\label{sec:createsources}

Run nuweb, but suppress the creation of the \LaTeX{} documentation.
Nuweb creates only sources that do not yet exist or that have been
modified. Therefore make does not have to check this. However,
``make'' has to create the directories for the sources if they
do not yet exist.
@%This is especially important for the directories
@%with the \HTML{} files. It seems to be easiest to do this with a shell
@%script.
So, let's create the directories first.

@d parameters in Makefile @{@%
MKDIR = mkdir -p

@| MKDIR @}



@d make targets @{@%
DIRS = @< directories to create @>

\$(DIRS) : 
	\$(MKDIR) \$@@

@| DIRS @}


@d make targets @{@%
sources : m4_progname.w \$(DIRS)
@%	cp ./createdirs m4_bindir/createdirs
@%	cd m4_bindir && chmod 775 createdirs
@%	m4_bindir/createdirs
	\$(NUWEB) m4_progname.w

jetty : sources
	cd .. && mvn jetty:run

@| @}

@%@o createdirs @{@%
@%#/bin/bash
@%# createdirs -- create directories
@%`#' m4_header
@%@< create directories @>
@%@| @}


\section{References}
\label{sec:references}

\subsection{Literature}
\label{sec:literature}

\bibliographystyle{plain}
\bibliography{m4_progname}

\subsection{URL's}
\label{sec:urls}

\begin{description}
\item[Nuweb:] \url{m4_nuwebURL}
\item[Apache Velocity:] \url{m4_velocityURL}
\item[Velocitytools:] \url{m4_velocitytoolsURL}
\item[Parameterparser tool:] \url{m4_parameterparserdocURL}
\item[Cookietool:] \url{m4_cookietooldocURL}
\item[VelocityView:] \url{m4_velocityviewURL}
\item[VelocityLayoutServlet:] \url{m4_velocitylayoutservletURL}
\item[Jetty:] \url{m4_jettycodehausURL}
\item[UserBase javadoc:] \url{m4_userbasejavadocURL}
\item[VU corpus Management development site:] \url{http://code.google.com/p/vucom} 
\end{description}

\section{Indexes}
\label{sec:indexes}


\subsection{Filenames}
\label{sec:filenames}

@f

\subsection{Macro's}
\label{sec:macros}

@m

\subsection{Variables}
\label{sec:veriables}

@u

\end{document}

% Local IspellDict: british 

% LocalWords:  Webcom
