# Gitops - Automated Kubernetes deployments with Cluster State enforcement. 
* The entire system is described declaratively.
* The canonical desired system state is versioned (with Git)
* Approved changes to the desired state are automatically applied to the system
* Software agents ensure correctness
# Problem
Kubernetes has too many components to effectively manage manually. Clusters need a lot of configuration in place to work as expected. Cluster configs also evolve over time as teams become more experienced. So who is going to keep track of all these changes?
What happens when someone with access to the cluster deletes something and things go haywire? Or worse, what happens if you lose your cluster completely (all etcd data gone), how can you recover? and how quickly?
With so many moving parts it makes it very difficult to keep up with all the changes. If changes are being applied from the command line on local laptops, how can you keep track of what changed, when, where, and who approved it? Also, what is the rollback strategy? If the person who made the change in the first place is not available now, you first must figure out what changes were made in the first place. This is a waste of time.
All the above scenarios are tedious, error prone, not scalable, and not easily repeatable. They all require too much inside knowledge, making it very difficult to on board new team members into the management (or lack thereof) flow.
There needs to be some sort of system in place that has the ability to enforce desired state. This is very similar to how many configuration management systems (like Puppet and Chef) manage state.
# Solution
Why don't we offload all of the change management stuff to Git? It already does a great job at this. We can require a Pull Request for any changes that will affect cluster state and we can 100% know who what did, when they did it, where they did it, who approved it, etc. It is 100% auditable.
Rollbacks become as easy as running git reset in most situations.
To help with the problem of random engineers running random commands on their own laptops to makes changes to the cluster, we just STOP. NO MORE DEPLOYMENTS BY HUMANS!!!!!! Everything becomes a pull request, review, approve, merge, observe workflow.
Let the system take care of deploying the code committed to the gilt repo. Let the system detect configuration drift and apply the changes to the cluster.
This makes everything auditable, scalable, and repeatable. Since all the cluster configuration is defined inside the repo, it becomes trivial to spin up a new cluster just like "that" one. It makes it trial to restore cluster state from a downed cluster. It also removes the requirement of team members needing to possess any "special knowledge" or any in-depth knowledge about a cluster, or Kubernetes for that matter, to be able to provide helpful contributions.
As a bonus, it will also allow anybody that has read access to this repo (which should be anybody who can login to GITHUB) the ability to create a Pull Request and propose changes to any cluster. That means developers can create PR's for their own deployments if they wanted to. Once changes are reviewed, approved, and finally merged they will be released into the target cluster(s) within minutes.
# So how does it handle helm deployments?
This is where the flux-helm operator comes into the picture. If you want to do a Helm deployment than you must supply a CRD (custom resource definition) object called "HelmRelease" (more info on CRD can be found here https://kubernetes.io/docs/tasks/access-kubernetes-api/custom-resources/custom-resource-definitions/). This special HelmRelease resource object is what will be applied by the flux operatoror once the changes are commited to your git repo. Once the HelmRelease object is deployed into the cluster the flux-helm operator (which is listening for these types of resources) will read the object, parse all the values, pull the referenced helm chart and deploy the chart with all of the custom values that were supplied in the HelmRelease object.

# How to Install Flux in your kubernetes cluster?
I have written a script to make the work easy. So, all you need to do is as below steps.

1. helm repo add fluxcd https://charts.fluxcd.io 
2. Generate a SSH key.
3. Change the variable value of "GIT_REPO" to your git repo and "git.user" to your username.
4. Make flux.sh file as an executable file
5. Run the script as ./flux.sh /path/to/private.key_generated
6. Once helm deployed run "kubectl -n flux logs deployment/flux | grep identity.pub | cut -d '"' -f2" and get the key copied and paste to github --> setting --> Deploy keys

Below is an example of a deployment of Ingress controller

![alt text](https://github.com/iflan7744/gitops/blob/master/ingress-controller-gitops.png)

# Repository Layout
We can choose to follow folder structure per cluster format. Here I have used simple as Cluster because I have only one cluster. What ever inside cluster folder get reflect to the K8s environment. Even if we manually delete a deployment from the cluster without doing changes to repo it will get deploy within few minutes.

### Note: - In script you can change the path of git where the changes need to get reflecte  "--set git.path="cluster" "

#### gitops/cluster/ingress/shared-ingress.yaml



