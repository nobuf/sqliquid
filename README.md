# sqliquid

Continuous development for sql lovers.

## Getting Started

### OX 10.10.2+

1. Open Terminal.app and type `git` and hit enter key. If you don't have `git` yet, a dialog navigates you to install it.

2. Download sqliquid:

        # go any folder you like
        cd ~/Documents
        git clone https://github.com/nobuf/sqliquid.git

3. Install dependencies:

        # install Homebrew (http://brew.sh/)
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        # install PostgreSQL
        brew install postgresql
        cd sqliquid
        # install gems
        sudo gem install bundle
        sudo ARCHFLAGS="-arch x86_64" gem install pg
        bundle install

4. Run sqliquid with database name etc (works with PostgreSQL), a directory that your SQL files sit.

        SQLIQUID_DATABASE="dbname=abc port=5432" ruby run.rb -d ~/change-this-to-your-folder/ -s

5. Open a browser, go to `http://localhost:4567/`
6. Edit and save SQL files, see the result on the browser.

## Update

        # stop the process with Ctrl-C
        git pull origin master
        bundle install

## Troubleshoot

1. Remove `db/sqliquid.db` and restart the process

## License

sqliquid is released under the [MIT License](http://www.opensource.org/licenses/MIT).
