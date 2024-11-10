# Instructions to Run the Codebase

This guide provides detailed instructions on how to set up, run, and test the entire codebase. Follow the steps below to get the application up and running.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Project Structure](#2-project-structure)
3. [Setting Up the Project](#3-setting-up-the-project)
4. [Installing Dependencies](#4-installing-dependencies)
5. [Running the Application](#5-running-the-application)
6. [Running the Test Suite](#6-running-the-test-suite)
7. [Additional Information](#7-additional-information)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Prerequisites

Before you begin, ensure that you have the following software installed on your system:

- **Ruby**: Version 2.7 or higher. You can check your Ruby version by running:

  ```bash
  ruby -v
  ```

- **Bundler**: For managing gem dependencies. Install it by running:

  ```bash
  gem install bundler
- ```

## 2. Project Structure
The codebase is organized as follows:

  ```bash
  billing_system/
    ├── .rspec
    ├── app.rb
    ├── app/
    │   └── models/
    │   │   └── subscription.rb
    ├── config/
    │   └── boot.rb
    ├── Gemfile
    ├── Gemfile.lock
    ├── lib/
    │   ├── api/
    │   │   ├── api_client.rb
    │   │   └── payments/
    │   │       ├── constants.rb
    │   │       ├── gateway.rb
    │   │       └── response.rb
    │   ├── billing_service.rb
    │   ├── payment_processor.rb
    │   ├── payment_scheduler.rb
    │   └── rebill_logger.rb
    ├── spec/
    │   ├── lib/
    │   │   ├── api/
    │   │   │   └── payments/
    │   │   │       ├── gateway_spec.rb
    │   │   │       └── response_spec.rb
    │   │   ├── billing_service_spec.rb
    │   │   ├── payment_processor_spec.rb
    │   │   ├── payment_scheduler_spec.rb
    │   │   └── models/
    │   │       └── subscription_spec.rb
    │   └──── spec_helper.rb
    ├── payment_gateway_api.rb
    └── README.md
  ```

## 3. Setting Up the Project
**Clone the Repository or Create a New Directory**

If you’re working with an existing repository, clone it:
```bash
git clone <repository_url> rebilling_system
cd rebilling_system
```
## 4. Installing Dependencies
***Install Gems with Bundler***

Run the following command to install the dependencies specified in the Gemfile:
```bash
bundle install
```
## 5. Running the Application

**a. Start the Payment Gateway API**

The payment gateway API is simulated using a Sinatra application located in lib/payment_gateway_api.rb. You need to start this server first.

**In Terminal Tab 1:**
```
ruby payment_gateway_api.rb
```

***Expected Output:***
```
== Sinatra (v3.2.0) has taken the stage on 4567 for development with backup from Puma
Puma starting in single mode...
* Puma version: 6.3.1 (ruby 2.6.5-p114) ("Mugi No Toki Itaru")
*  Min threads: 0
*  Max threads: 5
*  Environment: development
*          PID: 53417
* Listening on http://127.0.0.1:4567
* Listening on http://[::1]:4567
Use Ctrl-C to stop
```

***b. Run the Main Application***
```
ruby app.rb
```

***Expected Output:***
```
I, [2024-11-08T18:51:22.716650 #70443]  INFO -- : For testing purposes the default balance is $75.0 per card.
I, [2024-11-08T18:49:45.951551 #69997]  INFO -- : Billing Subscription $100_sub...
I, [2024-11-08T18:49:45.957078 #69997]  INFO -- : Insufficient funds for $100.0 on subscription $100_sub.
I, [2024-11-08T18:49:45.958227 #69997]  INFO -- : Successfully charged $75.0 for subscription $100_sub.
I, [2024-11-08T18:49:45.958245 #69997]  INFO -- : Remaining balance for subscription $100_sub: $25.0.
I, [2024-11-08T18:49:45.958855 #69997]  INFO -- : Scheduled additional transaction for subscription $100_sub on 2024-11-15
I, [2024-11-08T18:49:45.958872 #69997]  INFO -- : Billing Subscription $75_sub...
I, [2024-11-08T18:49:45.959519 #69997]  INFO -- : Successfully charged $75.0 for subscription $75_sub.
I, [2024-11-08T18:49:45.960037 #69997]  INFO -- : Remaining balance for subscription $75_sub: $0.0.
I, [2024-11-08T18:49:45.960049 #69997]  INFO -- : Billing Subscription $50_sub...
I, [2024-11-08T18:49:45.960647 #69997]  INFO -- : Successfully charged $50.0 for subscription $50_sub.
I, [2024-11-08T18:49:45.960657 #69997]  INFO -- : Remaining balance for subscription $50_sub: $0.0.
I, [2024-11-08T18:49:45.960665 #69997]  INFO -- : Rebilling Subscription $100_sub...
I, [2024-11-08T18:49:45.961214 #69997]  INFO -- : Insufficient funds for $25.0 on subscription $100_sub.
```

## 6. Running the Test Suite

***a. Run All Tests***
```
rspec spec
```

***b. Expected Test Output***
```
Finished in 0.0235 seconds (files took 0.39416 seconds to load)
38 examples, 0 failures
```

## 7. Additional Information
***Modifying Subscription Details***

In app.rb, you can modify the subscription details:
```
subscription = Subscription.new(
  id: 'sub_12345',
  price: 100.0,
  subscription_type: :monthly,
  start_date: Date.today
)
```

## 8. Troubleshooting

***a. Port Conflicts***

If you encounter an error stating that port 4567 is already in use, you can change the port number in lib/payment_gateway_api.rb:
```
set :port, 4568
```
Also, update the API_BASE_URL in ```lib/api/payments/constants.rb```:
```
API_BASE_URL = 'http://localhost:4568'
```

***b. Missing Gems***

If you receive LoadError messages, ensure that all gems are installed by running:
```
bundle install
```