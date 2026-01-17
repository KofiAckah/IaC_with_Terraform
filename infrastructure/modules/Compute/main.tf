# Data source to get the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# User data script to install Nginx and create HTML file
locals {
  user_data = <<-EOF
              #!/bin/bash
              # Update package index
              apt-get update -y
              
              # Install Nginx
              apt-get install -y nginx
              
              # Create a simple HTML file
              cat > /var/www/html/index.html <<HTML
              <!DOCTYPE html>
              <html lang="en">
              <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>IaC with Terraform - ${var.environment}</title>
                  <style>
                      body {
                          font-family: 'Arial', sans-serif;
                          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                          display: flex;
                          justify-content: center;
                          align-items: center;
                          height: 100vh;
                          margin: 0;
                          color: #fff;
                      }
                      .container {
                          text-align: center;
                          background: rgba(255, 255, 255, 0.1);
                          padding: 50px;
                          border-radius: 20px;
                          box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
                          backdrop-filter: blur(4px);
                          border: 1px solid rgba(255, 255, 255, 0.18);
                      }
                      h1 {
                          font-size: 3em;
                          margin-bottom: 20px;
                          text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
                      }
                      .info {
                          background: rgba(255, 255, 255, 0.2);
                          padding: 20px;
                          border-radius: 10px;
                          margin: 20px 0;
                      }
                      .info p {
                          margin: 10px 0;
                          font-size: 1.2em;
                      }
                      .badge {
                          display: inline-block;
                          padding: 5px 15px;
                          background: rgba(255, 255, 255, 0.3);
                          border-radius: 20px;
                          margin: 5px;
                      }
                      .footer {
                          margin-top: 30px;
                          font-size: 0.9em;
                          opacity: 0.8;
                      }
                  </style>
              </head>
              <body>
                  <div class="container">
                      <h1>🚀 Welcome to My Infrastructure!</h1>
                      <div class="info">
                          <p><strong>Project:</strong> ${var.project_name}</p>
                          <p><strong>Environment:</strong> <span class="badge">${var.environment}</span></p>
                          <p><strong>Deployed with:</strong> <span class="badge">Terraform</span></p>
                          <p><strong>Web Server:</strong> <span class="badge">Nginx</span></p>
                          <p><strong>Instance Type:</strong> <span class="badge">${var.instance_type}</span></p>
                          <p><strong>Region:</strong> <span class="badge">${var.aws_region}</span></p>
                      </div>
                      <div class="info">
                          <p><strong>Hostname:</strong> $(hostname)</p>
                          <p><strong>IP Address:</strong> $(hostname -I | awk '{print $1}')</p>
                      </div>
                      <div class="footer">
                          <p>Powered by Infrastructure as Code 💻</p>
                      </div>
                  </div>
              </body>
              </html>
              HTML
              
              # Start and enable Nginx
              systemctl start nginx
              systemctl enable nginx
              
              # Set proper permissions
              chmod 644 /var/www/html/index.html
              chown www-data:www-data /var/www/html/index.html
              EOF
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  user_data = local.user_data

    tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-app-server"
    }
  )
}