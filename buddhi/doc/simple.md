# Traffic profile: Simple

# Provisioning required for valid traffic
 - 1 provider key
   - 1 service
     - 1 metric
     - 1 app
       - 1 app key
     - 1 app plan
     - 1 usage limit

# Traffic profile

This is the simplest traffic profile.
Http traffic consists of single request at a given rate of requests per second.
The request refer to the provisioned service and will contain the provisioned app key.
