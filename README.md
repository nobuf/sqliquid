# sqliquid

Continuous development for sql lovers.

## Getting Started

1. Install ruby and dependencies:

        gem install bundle
        bundle install

2. Run sqliquid with database name etc (works with PostgreSQL), a directory that your SQL files sit.

        SQLIQUID_DATABASE="dbname=abc port=5432" ruby run.rb -d ~/abc/sql-files/ -s

3. Open a browser, go to `http://localhost:5432/`
4. Edit and save SQL files, see the result on the browser.

## License

sqliquid is released under the [MIT License](http://www.opensource.org/licenses/MIT).
