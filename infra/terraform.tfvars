location = "europe-west1"
project_name = "vyusufcan"


repository_id = "flaskapp"
respository_description = "flaskapp docker registry"
format = "DOCKER"

cloud_build_trigger_name = "flaskapp"
branch_name = "main"
repo_name = "github_vyusufcan_flask-app"


cloud_deploy_target_name = "dev"
require_approval = false
cloud_run_location =  "projects/vyusufcan/locations/europe-west1"


delivery_pipeline_name = "flaskapp"
profiles = []