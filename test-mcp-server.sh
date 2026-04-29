#!/bin/bash
# MCP Server Diagnostic Script
# Run this on your VPS to test the Computer Use MCP Server

SERVER_URL="${1:-https://computer.algotechbuilds.io}"
MCP_API_KEY="${2:-}"

echo "=========================================="
echo "Computer Use MCP Server Diagnostics"
echo "Server: $SERVER_URL"
echo "=========================================="
echo ""

# Test 1: Health Check
echo "1. Testing Health Endpoint..."
curl -s -o /dev/null -w "   HTTP Status: %{http_code}\n" "$SERVER_URL/health"
echo ""

# Test 2: Root Endpoint (HTML Documentation)
echo "2. Testing Root Endpoint (HTML Docs)..."
curl -s -o /dev/null -w "   HTTP Status: %{http_code}\n" "$SERVER_URL/"
echo ""

# Test 3: MCP Initialize (JSON-RPC)
echo "3. Testing MCP Initialize..."
if [ -z "$MCP_API_KEY" ]; then
    echo "   Warning: No MCP_API_KEY provided, trying without auth..."
    curl -s -X POST "$SERVER_URL/mcp" \
      -H "Content-Type: application/json" \
      -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' \
      | jq . 2>/dev/null || curl -s -X POST "$SERVER_URL/mcp" \
      -H "Content-Type: application/json" \
      -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}'
else
    echo "   Using provided API key..."
    curl -s -X POST "$SERVER_URL/mcp" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $MCP_API_KEY" \
      -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' \
      | jq . 2>/dev/null || curl -s -X POST "$SERVER_URL/mcp" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $MCP_API_KEY" \
      -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}'
fi
echo ""

# Test 4: Check if port 8081 is exposed correctly
echo "4. Checking if Coolify is routing correctly..."
echo "   The /mcp endpoint should return a session ID in the response headers."
echo "   Look for 'mcp-session-id' header in the response above."
echo ""

# Test 5: MCP Tools List
echo "5. Testing MCP tools/list..."
if [ -z "$MCP_API_KEY" ]; then
    curl -s -X POST "$SERVER_URL/mcp" \
      -H "Content-Type: application/json" \
      -d '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
      | jq '.result.tools[] | {name: .name, description: .description}' 2>/dev/null || echo "   Needs auth or server not ready"
else
    curl -s -X POST "$SERVER_URL/mcp" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $MCP_API_KEY" \
      -d '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
      | jq '.result.tools[] | {name: .name, description: .description}' 2>/dev/null || echo "   Error fetching tools"
fi
echo ""

echo "=========================================="
echo "Diagnostic Complete!"
echo "=========================================="
echo ""
echo "NEXT STEPS FOR N8N:"
echo "1. MCP Endpoint URL: $SERVER_URL/mcp"
echo "2. Headers to add in n8n:"
echo "   - Content-Type: application/json"
echo "   - Authorization: Bearer <YOUR_MCP_API_KEY>"
echo ""
echo "If MCP_API_KEY is set in Coolify, use that value."
echo "If MCP_API_KEY is empty, the server allows unauthenticated access."
