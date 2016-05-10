<div align="center">
<h1>Steno</h1>
<img src="./assets/steno.png"/>
</div>

> based on https://github.com/fitztrev/shuttle

Running scripts is a breeze when you can run your scripts with other scripts, but don't you hate opening up terminal?

Steno is a place to put all those scripts in plain site separated by your own grouping (work, home, garden, etc)

Current features that Steno supports

# Example Configuration

```
{
  "groups": [
    {
      "name": "testing",
      "commands": [
        {
          "name": "echo",
          "command": "echo 'testing'",
          "type": "background"
        },
        {
          "name": "echo input",
          "command": "echo 'hello {name}'",
          "args": {
            "name": "Please enter your name"
          },
          "type": "background"
        },
        {
          "name": "copy",
          "command": "echo 'check this out' | pbcopy",
          "type": "async"
        },
        {
          "name": "cd",
          "command": "cd;cd Desktop;",
          "type": "async"
        },
        {
          "name": "mkdir",
          "command": "cd;cd Desktop;mkdir steno;",
          "type": "async"
        },
        {
          "name": "curl",
          "command": "curl -i www.google.com",
          "type": "async"
        },
        {
          "name": "curl and write to file",
          "command": "cd;cd Desktop;mkdir steno;cd steno;curl www.google.com > google.html",
          "type": "async"
        },
        {
          "name": "input echo",
          "command": "echo \"your name is {name}\"",
          "args": {
            "name": "What is your name"
          },
          "type": "async"
        }
      ]
    }
  ]
}
```
