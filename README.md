#Docker Skeletons

```
//alias script
function site_init_script {
    script_dir=/Users/michaeltoriola/Projects/Resources/docker/resources/scripts/site-init.sh
    echo ${script_dir}
}
alias site_init_script="site_init_script"
```
bash $(site_init_script) --DOMAIN site.com --PORT 18099 --DB_NAME site_db —DB_USERNAME root —DB_PASSWORD password
```