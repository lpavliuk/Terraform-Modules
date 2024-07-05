variable "client_url" {
  type        = string
  nullable    = false
  description = <<-EOF
    Client URL. For example: `https://example.com`
  EOF
}

variable "client_id" {
  type        = string
  nullable    = false
  description = <<-EOF
    Client ID that will be registered and used to identify an application. For example: `api.example.com`
  EOF
}

variable "client_tls_sha1_fingerprint" {
  type        = string
  default     = ""
  description = <<-EOF
    Client URL Certificate SHA1 Fingerprint

    **NOTE!** Must contain 40 alphanumeric characters (SHA1 HASH) without `:`.

    `9E:11:A4:22:92:70:33:49:26:AB:7F:3B:02:CC:2D:A3:00:AB:72:XX`  => `"9E11A4229270334926AB7F3B02CC2DA300AB72XX"`
  EOF

  validation {
    condition     = can(regex(
      "^[a-fA-F0-9]{40}$",
      var.client_tls_sha1_fingerprint
    ))
    error_message = <<-EOF
      Must contain 40 alphanumeric characters (SHA1 HASH).
    EOF
  }
}

variable "match_field" {
  type        = string
  default     = "sub"
  description = <<-EOF
    Match Field.

    Available values:
      - `"sub"` (Subject)
      - `"aud"` (Audience)
  EOF

  validation {
    condition     = contains(["aud", "sub"], var.match_field)
    error_message = <<-EOF
      Only the following values are available:
        - "sub"
        - "aud"
    EOF
  }
}

variable "match_values" {
  type        = list(string)
  default     = []
  description = <<-EOF
    Value of the Subject Match Field.

    For example, for GitLab:
      - specific project, main branch: `"project_path:mygroup/myproject:ref_type:branch:ref:main"`
      - all projects under a group: `"project_path:mygroup/*:ref_type:branch:ref:main"`
  EOF
}
