#include <glob.h>

std::vector<std::string> glob(const char *pattern) {
  glob_t g;
  glob(pattern, GLOB_TILDE, nullptr, &g);  // one should ensure glob returns 0!
  std::vector<std::string> filelist;
  filelist.reserve(g.gl_pathc);
  for (size_t i = 0; i < g.gl_pathc; ++i) {
    filelist.emplace_back(g.gl_pathv[i]);
  }
  globfree(&g);
  return filelist;
}

void mergeTrees(TString inputfiles, TString outputbase, int entries_per_output = 100000, TString treename = "tree") {
  TChain *chain = new TChain("tree");
  auto files = glob(inputfiles);
  for (const auto &filepath : files) {
    std::cerr << "Adding " << filepath << std::endl;
    chain->Add(filepath.c_str());
  }
  int total_entries = chain->GetEntries();

  std::cerr << "Loaded " << files.size() << " files, " << total_entries << " entries" << std::endl;

  float jet_pt = 0;
  chain->SetBranchAddress("jet_pt", &jet_pt);

  int ifile = 0;
  int counts = 0;

  TFile *fout = nullptr;
  TTree *outtree = nullptr;

  for (int i = 0; i < total_entries; ++i) {
    if (counts == 0) {
      fout = new TFile(outputbase + "_" + TString::Format("%03d", ifile) + ".root", "RECREATE");
      fout->cd();
      outtree = chain->CloneTree(0);
    }

    chain->GetEntry(i);
    if (!(jet_pt > 500 && jet_pt < 1000))
      continue;

    outtree->Fill();
    ++counts;

    if (counts == entries_per_output) {
      std::cerr << i << " processed. "
                << "Written output file " << fout->GetName() << std::endl;
      fout->Write();
      fout->Close();
      delete fout;
      counts = 0;
      ++ifile;
    }
  }
}
