# Rails SaaS Starter App (aka Rails SaaS Template)

## Introduction
Rails SaaS Starter App is a starter application for your next SaaS application.
This is not a Rails Engine. The goal is provide you with a robust code base
that you can use to start buidling your next SaaS app.

## How to use Rails SaaS Starter App
1. Create a repository for your new application
1. Download a copy of Rails SaaS Starter App
1. Copy the source from Rails SaaS Starter App into your application
1. Start coding

## Why should I use it?
Out of the box you get many things that would take you hours to code including
1. Multi-tenant support (currently path based easily modified)
1. Pricing page
1. Account registration
1. Account management (admin)
1. Plan management (admin)
1. User management (admin)
1. User invitations (admin and settings)
1. Event viewer (admin)
1. Change plans (settings)
1. Update create card (settings)
1. Cancel account (settings)

## Multi-tenant support
Out of the box plans support path based multi-tenancy. You can enable hostname
and subdomain multi-tenancy on a per plan basis however it make it work you
are going to want to make some changes inside Account#find_account() and your
config/routes.rb file.

At the moment it look up an account by hostname or subdomain if there is no
:path parameter but there always is because thats how the routes are setup.
By default it also doesn't enforce any particular URL. So if your app was
hosted at app.my-app.com someone could CNAME app.their-domain.com and make
it appear like it was running on their domain.

If that's a problem then I would recommend modifying Account#find_account() to
make sure that the hostname is the hostname you use for your application and
only allow other subdomains or hostnames when the plan allows those features.