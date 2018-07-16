# perftest-toolkit

[![Docker Repository on Quay](https://quay.io/repository/3scale/perftest-toolkit/status "Docker Repository on Quay")](https://quay.io/repository/3scale/perftest-toolkit)
[![CircleCI](https://circleci.com/gh/3scale/perftest-toolkit.svg?style=shield)](https://circleci.com/gh/3scale/perftest-toolkit)


This repo has tools and deployment configs for a performance testing environment to be able to run performance tests of a 3scale API Management solution, focussing on the traffic intensive parts of the solution (the API Gateway and the Service Management API).

We have open sourced it to enable partners, customers and support engineers to run their own performance tests on "self-managed" (i.e. Not SaaS) installations of the 3scale API Management solution.

By running performance test with the same tools, scripts, traffic patterns and measurements as we at 3scale do, we hope it will help produce results that can be more easily compared with the results we achieve in our regular in-house performance testing and that we can run internally.

The goal is to help to resolve doubts or issues related to scalability or performance more quickly and easily - allowing you to achieve the high levels of low-latency performance we strive for and ensure in our own internal testing. 

![Test setup](/deployment/doc/infrastructure.png "Infrastructure")

## [Deployment](/deployment) - 3Scale AMP service setup for testing

## [Buddhi](/buddhi) - 3Scale AMP service setup and traffic generation tool
