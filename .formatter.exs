[
  line_length: 120,
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  subdirectories: ["apps"],
  import_deps: [:ecto, :phoenix]
]
