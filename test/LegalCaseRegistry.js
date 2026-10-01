const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LegalCaseRegistry", function () {
  async function deployRegistry() {
    const [owner, caseWorker, outsider] = await ethers.getSigners();
    const Registry = await ethers.getContractFactory("LegalCaseRegistry");
    const registry = await Registry.deploy();
    await registry.waitForDeployment();
    return { registry, owner, caseWorker, outsider };
  }

  it("authorizes the deployer and lets the owner grant access", async function () {
    const { registry, owner, caseWorker, outsider } = await deployRegistry();
    expect(await registry.isAuthorized(owner.address)).to.equal(true);
    await registry.grantAccess(caseWorker.address);
    expect(await registry.isAuthorized(caseWorker.address)).to.equal(true);
    await expect(registry.connect(outsider).grantAccess(outsider.address)).to.be.revertedWith("Only owner");
  });

  it("creates and versions a case record by document hash", async function () {
    const { registry, caseWorker } = await deployRegistry();
    const caseId = ethers.id("random-demo-case-id-001");
    const firstHash = ethers.keccak256(ethers.toUtf8Bytes("encrypted document version one"));
    const secondHash = ethers.keccak256(ethers.toUtf8Bytes("encrypted document version two"));
    await registry.grantAccess(caseWorker.address);
    await expect(registry.connect(caseWorker).createCase(caseId, firstHash))
      .to.emit(registry, "CaseCreated").withArgs(caseId, firstHash, caseWorker.address, 1);
    await registry.connect(caseWorker).updateDocumentHash(caseId, secondHash);
    const record = await registry.connect(caseWorker).getCase(caseId);
    expect(record.documentHash).to.equal(secondHash);
    expect(record.version).to.equal(2);
  });

  it("rejects unauthorized actions and prevents changes after archival", async function () {
    const { registry, caseWorker, outsider } = await deployRegistry();
    const caseId = ethers.id("random-demo-case-id-002");
    const documentHash = ethers.keccak256(ethers.toUtf8Bytes("encrypted document"));
    await expect(registry.connect(outsider).createCase(caseId, documentHash)).to.be.revertedWith("Not authorized");
    await registry.grantAccess(caseWorker.address);
    await registry.connect(caseWorker).createCase(caseId, documentHash);
    await registry.connect(caseWorker).archiveCase(caseId);
    await expect(registry.connect(caseWorker).updateDocumentHash(caseId, documentHash)).to.be.revertedWith("Case is archived");
  });

  it("allows the owner to revoke an authorized account", async function () {
    const { registry, caseWorker } = await deployRegistry();
    await registry.grantAccess(caseWorker.address);
    await registry.revokeAccess(caseWorker.address);
    expect(await registry.isAuthorized(caseWorker.address)).to.equal(false);
    await expect(registry.connect(caseWorker).getCase(ethers.id("unknown"))).to.be.revertedWith("Not authorized");
  });
});
