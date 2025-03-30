# Laravel Application Dockerfile with mount type Secrets

This is simple example of laravel application containerized with docker in which secrets are injected on the build time or can be injected with using secrets in a Pipeline.

## Example Usage

```bash
echo "${{ secrets.PRIVATE_KEY_STAGE }}" > private_key.pem

docker build --secret id=private_key,src=private_key.pem -t ${{ env.ECR_REPOSITORY_URI }}:$GITHUB_SHA .
```

*The above example is just one use case of using mount type secret in a Github Actions Pipeline.*
