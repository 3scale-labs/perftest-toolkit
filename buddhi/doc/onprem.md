# Traffic profile: Onprem

# Provisioning required for valid traffic
 - 1 provider keys
   - 3 services
     - 3 metrics
     - 100 app
       - 1 app key
     - 3 app plan
     - 2 usage limit per (metric, plan)

# Traffic profile

Every request will refer to a random provider key and associated random service.
Application authentication is carried out either:
  - By **user_key** (*backend_version* = 1)
  - By **app_id** and **app_key** (*backend_version* = 2)
with the same probability.

Regarding metrics, every request will refer to a random number of associated metrics.
This random number of metrics has the following probability distribution:
  - 70% requests: 1 metrics
  - 20% requests: 2 metrics
  - 10% requests: 3 metrics

More information:

 - *GET /transactions/authorize.xml* requests not implemented.

 - *POST /transactions.xml* requests not implemented.

 - *oauth* requests not implemented.

 - No *service_tokens* generated. Request authentication using *provider_key*

 - All metrics inherit from *hits* default metric
