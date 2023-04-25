```
"assets/(.*?)" -> "<%= Routes.static_path(@conn, "/$1") %>"
```
