# TODO: Computer Use MCP Server Deployment

> **Status**: In Progress  
> **Last Updated**: April 29, 2026  
> **Owner**: Drew (AlgoTech92)

---

## ✅ Completed Tasks

- [x] **Fix Nixpacks Configuration**
  - Removed invalid `[phases]` section from `nixpacks.toml`
  - Forced Python provider to skip npm install
  - Switched to Dockerfile deployment (bypasses Nixpacks entirely)

- [x] **Create Coolify Dockerfile**
  - New `Dockerfile` (Python 3.12-slim) for MCP server only
  - Renamed workspace `Dockerfile.workspace` → keeps original image build working
  - Updated `.dockerignore` to exclude unnecessary files

- [x] **Add SSE Transport Support**
  - Added `sse_path="/sse"` to FastMCP initialization
  - Enables n8n compatibility (SSE transport)
  - Streamable HTTP still available at `/mcp`

- [x] **Push Changes to GitHub**
  - All fixes committed and pushed to `main` branch
  - Coolify auto-redeployed successfully
  - Container is healthy and running

---

## 🚨 Active Issues

### **Issue: "error code: 1010" Blocking n8n Connection**

**Symptoms**:
- `curl https://computer.algotechbuilds.io/health` returns `error code: 1010`
- `curl https://computer.algotechbuilds.io/mcp` returns same error
- HTTP Status: `403 Forbidden`

**Diagnosis** (In Progress):
1. ~~**Cloudflare WAF/DDoS Protection**~~ → Tested, not the issue (paused Cloudflare, still blocked)
2. **Traefik Reverse Proxy** → Coolify's proxy might be blocking POST requests to `/mcp`
3. **MCP_API_KEY Authentication** → App might be returning 1010 on auth failure
4. **Container Port Mismatch** → Traefik might be proxying to wrong port

**Next Steps**:
- [ ] SSH into VPS and test **direct container access** (bypass Traefik/Cloudflare)
- [ ] Check **Traefik logs** in Coolify proxy container
- [ ] Temporarily **disable MCP_API_KEY** to test if auth is causing 1010
- [ ] Verify **container port mapping** in Coolify dashboard

---

## 📋 Pending Tasks

### **High Priority**
- [ ] **Resolve "error code: 1010" Issue**
  - Test direct container access (`docker inspect` + `curl http://172.17.0.X:8081/health`)
  - Check Coolify proxy (Traefik) logs
  - Test without MCP_API_KEY
  - Update n8n with correct transport settings

- [ ] **Connect n8n to MCP Server**
  - Configure n8n MCP Client node
  - Test Streamable HTTP transport (`/mcp`)
  - Test SSE transport (`/sse`) as fallback
  - Verify tool discovery and execution

### **Medium Priority**
- [ ] **Build Workspace Image on VPS**
  ```bash
  ssh your-vps
  cd /path/to/open-computer-use
  docker build -f Dockerfile.workspace --platform linux/amd64 -t open-computer-use:latest .
  ```

- [ ] **Mount Docker Socket in Coolify**
  - Advanced Settings → Storage
  - Host path: `/var/run/docker.sock`
  - Container path: `/var/run/docker.sock`
  - Mode: Read/Write

### **Low Priority**
- [ ] **Add Health Check Endpoint Verification**
  - Ensure `/health` returns proper JSON
  - Add readiness/liveness probes for Coolify

- [ ] **Document n8n Integration**
  - Create `docs/n8n-integration.md`
  - Include screenshots and example workflows
  - Add to README.md

---

## 🔗 Resources

| Resource | URL |
|----------|-----|
| **GitHub Repo** | https://github.com/AlgoTech92/open-computer-use |
| **Live Server** | https://computer.algotechbuilds.io |
| **MCP Endpoint (Streamable HTTP)** | https://computer.algotechbuilds.io/mcp |
| **MCP Endpoint (SSE)** | https://computer.algotechbuilds.io/sse |
| **Coolify Dashboard** | https://your-coolify-instance.com |
| **Cloudflare Dashboard** | https://dash.cloudflare.com |

---

## 📝 Notes

- **Error Code 1010**: Not a standard HTTP or Cloudflare error. Appears to be custom from the app or Traefik middleware.
- **n8n Transport**: Modern n8n supports Streamable HTTP, but SSE fallback is available.
- **Docker Socket**: Critical for MCP server to spawn workspace containers.

---

**Next Session Goal**: Resolve 1010 error and successfully connect n8n to MCP server! 🎯