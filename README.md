# Imagination Space

Imagination Space is a social networking and archive site.

## License

All source code for Imagination Space
is available jointly under the MIT License and the Beerware License. See
[LICENSE.md](LICENSE.md) for details.

## Getting starded

This software requires Ruby 2.4 and the latest version of rails as well as the usage of the PostgreSQL database.

In order to use this software, first install the necessary gems with "bundle install."

Next, in order to use this software locally, a Postgres database must be installed. Go to the Postgres website to download and install the database, and note the password of the root user, "postgres."

After installing postgres create a ".env" file that specifies the following environment variable connecting to the Postgres database:

PG_DEVELOPMENT_PASSWORD="(your password here)"

Next, migrate the database with "rails db:migrate."

Next, this software uses Amazon S3 as a file storage by default, but can also use the local filesystem. This requires the setup of an Amazon AWS account for setting up usage for S3. After creating the account, create a role that can read and write from the S3 store.

After this is done, add these environment variable definitions to your ".env" file:

S3_BUCKET="(bucket name here)"
S3_ACCESS_KEY="(access key here)"
S3_SECRET_KEY="(secret key here)"
S3_REGION="(region here)"

Also, this software uses the Uppy uploader along with Shrine for managing direct uploads to S3. To that end, please refer to the documentation about direct uploads on [Shrine's website](http://www.shrinerb.com) and refer to its [section on the CORS configuration](https://shrinerb.com/rdoc/files/doc/direct_s3_md.html#label-Bucket+CORS+configuration). Be sure to replace the relevant part of their supplied template with your own domain name.

It is also important to note that this software uses one package from npm to provide its tag inputs functionality, tagify. This requires installing node.js and running "npm install."

To summarize, after cloning or pulling from this repository:

1. Install Ruby 2.4 (if not already installed)
2. Run "bundle install"
3. Install postgres and note the password of the root user "postgres"
4. Create a .env file specifying the postgres password with "PG_DEVELOPMENT_PASSWORD="(your password here)
5. Run "rails db:migrate"
6. Create an Amazon AWS account (if you don't have one already) and create a role for writing and reading S3 stores
7. Add the definitions for S3_BUCKET, S3_ACCESS_KEY, S3_SECRET_KEY, and S3_REGION to the the .env file.
8. Check [Shrine's website](http://www.shrinerb.com) and copy their [CORS configuration template](https://shrinerb.com/rdoc/files/doc/direct_s3_md.html#label-Bucket+CORS+configuration) to your own. Replace the "https://my-app.com" with your own domain.
9. Install node.js (if not already installed) and run "npm install"
10. Run "rails server" and it will be up and running.
11. If desired, it can also be pushed onto Heroku. If this step is taken, be sure to also add the Sendgrid addon to send emails.

## To do list

* Finish writing tests for this software using Rspec and find out why Capybara isn't attaching images correctly.
* Clean up code duplication in the articles and article_pages controllers.
* Solve the N+1 database querying issues that arise from unnecessary usage of .present? and .count.
* Remove polymorphism and replace them with explicit supertables.
* Rename the ArticleTag and ArticleTaggings models to become more widely applicable.
* Implement ActivityPub so that content can be federated.
* Features to be added can be found on [the list of features to be added](www.imaginationspace.org/about).