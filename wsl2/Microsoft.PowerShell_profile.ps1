Set-Alias -Name g -Value git
Set-Alias -Name d -Value docker
Set-Alias -Name dc -Value 'docker-compose'
Set-Alias -Name ca -Value cargo

function dotenv() {
    get-content .env | foreach {
        $name, $value = $_.split('=')
        set-content env:\$name $value
    }
}