FROM wyveo/nginx-php-fpm:php74

WORKDIR /usr/share/nginx/
RUN rm -rf /usr/share/nginx/html

COPY . /usr/share/nginx

# NGINX Config http://localhost/*
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Install dependencies
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip


# Install Drivers MS ODBC Driver

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql17
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN echo source ~/.bashrc
RUN apt-get install -y unixodbc-dev
RUN apt-get install -y libgssapi-krb5-2
RUN apt-get install -y --allow-downgrades libssl1.1=1.1.1d-0+deb10u6
RUN apt-get install -y libssl-dev
RUN apt-get install -y php7.4-dev
RUN pecl install sqlsrv
RUN pecl install pdo_sqlsrv

RUN echo "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.4/mods-available/sqlsrv.ini
RUN echo "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.4/mods-available/pdo_sqlsrv.ini

RUN phpenmod sqlsrv pdo_sqlsrv

RUN ln -s public html