# Welcome To The Course

This course trains you for the **Project Management, RBAC & Multi-Tenancy** part of the Astrona **Harbor** training path. That part is 20% of the path. This page tells you who the course is for, what you can do at the end, which words and example setup it uses, and how its pages fit together.

## Who this course is for

You know your way around Kubernetes and `kubectl`, and you know what a container image, a tag and a digest are. You have used a JSON API with `curl`. You do not need to know Harbor's access control yet. Each new idea is explained the first time it appears.

## What you can do at the end

One Harbor often serves many teams. This course trains you to keep those teams apart, to keep their storage under control, and to let them sign in with the accounts they already have. It does not ask you to remember words: every skill ends with a push or a pull as a real user that works, or that is refused. The course has four topics.

The first topic is **projects and membership**. You will learn to:

- Create public and private projects with the `harbor` command-line tool and the REST API.
- Explain what each of the five member roles may do, from Limited Guest to Project Admin.
- Give every user the smallest role that lets them work, and prove it with pushes and pulls.

Storage grows quietly, so the second topic is **quotas, tag retention and immutability**. You will learn to:

- Set a storage quota on a project and explain how Harbor counts storage.
- Write a tag retention rule, check it with a dry run, and run it.
- Protect release tags with a tag immutability rule.

Most companies already keep their users somewhere else, so the last two topics are **identity integration**. You will learn to:

- Sign users in through an OpenID Connect (OIDC) provider, Keycloak, and use OIDC groups as project members.
- Sign users in through an LDAP directory, and use LDAP groups as project members.
- Make one group of users Harbor administrators, and give registry clients a CLI secret.

Everything is written for **Harbor v2.15.4** and the **Harbor CLI v0.0.27**.

## The words this course uses

The pages use Harbor's own terms, because those are the words you meet in the web portal, the API and the logs. Each term gets a short, plain definition the first time it appears on a page. A few terms come back on almost every page, so here they are up front.

A **project** is Harbor's unit of access control and storage; every repository lives in exactly one project. A **member** is a user or a group that has a **role** in a project. A **system administrator** may do everything in every project, and only a system administrator sets storage quotas. An **artifact** is anything stored in a repository, for example a container image; in this course most artifacts are small files pushed with `oras`.

The five project roles come back on every page of the first section:

| Role | In one sentence |
| --- | --- |
| Limited Guest | Can pull, but sees little of the project |
| Guest | Can pull and read the project |
| Developer | Can also push |
| Maintainer | Can also delete artifacts, scan and manage immutability rules |
| Project Admin | Can also manage members and robot accounts |

## The example setup in your playground

Every playground and lab runs Harbor in a small Kubernetes cluster on your machine, at the address `https://harbor.localtest.me:8443`. You run Harbor's tools in a pod called the **workstation**, which already trusts Harbor's certificate. The pages use a few example users (`alice`, `bob`, `carol`), team projects (`team-a`, `team-b`) and one shared project, `inventory`. The identity sections add Keycloak and an LDAP directory.

Many labs start with something set up wrong on purpose. That is the material, not a fault in the course.

## How the course is laid out

The course has four sections. It starts inside one Harbor, with projects and roles, then controls what those projects store, and ends by connecting Harbor to the places where users already live.

| Section | What it covers |
| --- | --- |
| 010 | Projects And Membership |
| 020 | Quotas, Tag Retention And Immutability |
| 030 | Identity Integration With OIDC |
| 040 | Identity Integration With LDAP |

Each section has one or more **modules**, and each module teaches one skill. A module brings together four kinds of material:

| What | What it is for | Graded? |
| --- | --- | --- |
| **Reading** | A short landing page, a few chapters that teach one idea each, and a summary | No |
| **Playground** | A small cluster on your own machine, to try everything you read | No |
| **Lab** | A cluster in a starting state, a task, and a grader that checks your work | Yes |
| **Capstone** | The last lab in a section, with several faults at once | Yes |

The best order is simple: read the chapters with the playground open next to them, take each lab when a chapter sends you to it, and finish each section with its capstone. The next part of this page explains how a module's pages guide you through that order.

## How to read a page

A module starts with a **landing page**. It says what the module teaches, what you should know first, and the order of its chapters. At the bottom of the landing page you start the module's playground, and you keep it running while you read.

The chapters (the parts of a module) read like the chapters of a technical book. Each one opens with the problem it solves, explains one idea in connected paragraphs, and closes with what you now know. The hands-on steps sit right in the text: a sentence or two on what to run and why, the command, and then what the result shows. Run each step in your playground as you reach it. You learn more from one real result than from a page of text.

Every chapter ends with a box of common pitfalls, the mistakes people make most often with what the chapter taught, and how to spot them. Now and then a page also has a tip box with a habit or shortcut you can use again, well beyond that page. The two boxes look like this:

> [!TIP]
> **A tip.** A habit or shortcut you can use again, well beyond this one page.

> [!WARNING]
> **Common pitfalls.** The mistakes people make most often with what you just learned, and how to spot them. Every chapter ends with one.

When a graded lab tests what a chapter taught, that chapter ends with a **Your mission** section. It tells you what the lab asks, then gives every command you need, in order: pause the playground with `astrona stop`, start the lab with `astrona run`, and send your work for grading with `astrona submit`. Solve the lab on your own before you look at its solution. When the lab is done, remove it with `astrona destroy` and start the playground again with `astrona start`, so you can carry on reading where you left off.

The last page of every module is the **Summary**. It sums up what you learned in a few short paragraphs, organised by idea. It also ends the module's hands-on work: the Summary page removes the playground, so your machine is clean before the next module.

One rule holds on every page. Code blocks are exactly what you type. Never change a command to make it "look right". If the result is different from what the page describes, that difference is the lesson.
