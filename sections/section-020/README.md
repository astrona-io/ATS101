# Section 020: Quotas, Tag Retention And Immutability

A registry only grows. Every build pushes a new tag, and nobody deletes the old ones until the disk is full. Harbor gives you three tools to stop that, each with a different job: a **storage quota** caps how much a project may store, a **tag retention rule** decides which artifacts to keep and deletes the rest, and a **tag immutability rule** protects chosen tags from being overwritten or deleted.

This section uses all three on one project. The three tools work together: retention keeps the newest builds, immutability protects the releases from retention and from careless pushes, and the quota catches everything the rules miss.

**Topic covered:** Storage control

## What you will learn

- How Harbor counts storage per project, and why a shared layer counts once per project.
- Setting a storage quota as system administrator, and what a push over the quota looks like.
- The five retention rule templates, matching and excluding tags, and how several rules combine.
- Running a retention policy as a dry run first, then for real.
- Tag immutability rules, and what they stop: re-pushing, re-tagging and deleting.
- How retention and immutability work together to keep releases safe.

## The learning path

### 1. Control Storage With Quotas, Retention And Immutability

The module starts at its landing page, which also launches the playground. The playground holds the private project `inventory` with seven small artifacts: `build-1` to `build-6` and `release-1.0`, pushed in that order.

1. Storage Quotas
2. Tag Retention Rules
3. Tag Immutability Rules, followed by the lab **Keep A Project Within Its Storage Budget**
4. Summary

## Section capstone: Stop Retention From Deleting Releases

The capstone is one graded scenario that combines the whole module. A retention policy runs every night and keeps exactly one artifact, the releases are not protected, and the quota is so small that the team can no longer push. Fix the policy before it runs. Work it after the module lab.

Start the capstone:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS101.git -c sections/section-020/capstone/labs/lab-01
```

When you think you are done, send it for grading:

```sh
astrona submit -c sections/section-020/capstone/labs/lab-01
```

When the capstone is done, remove it:

```sh
astrona destroy ats-101-capstone-020
```
