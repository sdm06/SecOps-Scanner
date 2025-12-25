{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "devsecops-env";

  buildInputs = with pkgs; [
    docker        # The Docker CLI
    trivy         # The Vulnerability Scanner
    jdk11         # Java runtime (required if running Jenkins agent locally)
    jenkins       # Optional: If you want to run a local Jenkins instance
    lazydocker
  ];

  shellHook = ''
    echo "🛡️ DevSecOps Environment Loaded"
    echo "Trivy Version: $(trivy --version | head -n 1)"
    echo "Docker Version: $(docker --version)"
    
    # Check if Docker daemon is accessible
    if ! docker info > /dev/null 2>&1; then
      echo "   WARNING: Docker daemon is not running or accessible."
    fi
  '';
}
