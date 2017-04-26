stage('Build & push images') {
  sh 'make build-kuma push-kuma'
}

stage('Deploy') {
  env.KUBECONFIG = "${env.HOME}/.kube/virginia.kubeconfig"
  env.DEIS_PROFILE = 'virginia'
  env.DEIS_BIN = 'deis2'
  env.DEIS_APP = 'mdn-' + env.BRANCH_NAME
  env.DJANGO_SETTINGS_MODULE = 'kuma.settings.prod'
  assert env.BRANCH_NAME.matches("[a-z0-9-]*[a-z0-9]")

  sh 'make deis-create-and-or-config'
  sh 'make render-k8s-templates'
  sh "KUBECONFIG=${env.KUBECONFIG} kubectl -n ${env.DEIS_APP} apply -f k8s/"
  sh 'make deis-pull'
  sh 'make deis-migrate'
  sh 'make demo-db-import'
  sh 'make deis-scale-api-and-worker'
}
