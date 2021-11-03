/*
    a) AFAIK, the use of project name has been deprecated so
        use projectId instead if you add anything. All 
        resources' instantiation will fail miserably after when deploying.
    b) US-WEST2 has all the features to use that region.
*/
locals {
    gcpRegion      = "us-west2"
    clusterZone    = "us-west2-a"
    gcpCredentials = file("")
    projectName    = ""
    projectId      = ""
    serviceAccount = ""
}