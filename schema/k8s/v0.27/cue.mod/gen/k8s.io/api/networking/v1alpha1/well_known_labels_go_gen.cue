// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go k8s.io/api/networking/v1alpha1

package v1alpha1

// TODO: Use IPFamily as field with a field selector,And the value is set based on
// the name at create time and immutable.
// LabelIPAddressFamily is used to indicate the IP family of a Kubernetes IPAddress.
// This label simplify dual-stack client operations allowing to obtain the list of
// IP addresses filtered by family.
#LabelIPAddressFamily: "ipaddress.kubernetes.io/ip-family"

// LabelManagedBy is used to indicate the controller or entity that manages
// an IPAddress. This label aims to enable different IPAddress
// objects to be managed by different controllers or entities within the
// same cluster. It is highly recommended to configure this label for all
// IPAddress objects.
#LabelManagedBy: "ipaddress.kubernetes.io/managed-by"
