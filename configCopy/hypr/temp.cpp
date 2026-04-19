#include <bits/stdc++.h>
using namespace std;

using vi = vector<int>;
// map t -> queue of all values in order of they were added
using entry = map<int, queue<int>>;

int main() {
  string s; cin >> s;
  int k; cin >> k;
  // Maps id -> entries
  unordered_map<string, entry> amp, bmp;

  int mx_t = -1;
  while(cin >> s) {
    string id;
    int t, val;
    cin >> id >> t >> val;
    mx_t = max(mx_t, t);
    bool is_a = (s == "push_a");
    entry& same = is_a ? amp[id] : bmp[id];
    entry& other = is_a ? bmp[id] : amp[id];

    // Remove stale entries. We can do this lazily by id
    auto removeStale = [&](entry& e) {
      while(!e.empty() && e.begin()->first < mx_t - k) {
        // cout << "erasing " << e.begin()->first << endl;
        e.erase(e.begin());
      }
    };
    removeStale(same);
    removeStale(other);

    // Find possible matches
    int best_diff = k;
    entry::iterator it = other.end();

    // Checking lit first and requiring strict improvements satisfies the tied -> earlier timestamp rule
    auto lit = other.upper_bound(val);
    if(lit != other.begin()) {
      lit = prev(lit);
      auto [o_t, q] = *lit;
      int dt = t - o_t;
      if(dt < best_diff) {
        best_diff = dt;
        it = lit;
      }
    }
    auto rit = other.lower_bound(val);
    if(rit != other.end()) {
      auto [o_t, q] = *lit;
      int dt = t - o_t;
      if(dt < best_diff) {
        best_diff = dt;
        it = rit;
      }
    }
    if(it != other.end()) {
      // Take the earliest value if we have multiple matching
      auto& [o_t, q] = *it;
      int o_val = q.front(); q.pop();
      if(q.empty()) other.erase(it);
      if(is_a) cout << id << " " << t << " " << val << " " << o_t << " " << o_val << endl;
      else     cout << id << " " << o_t << " " << o_val << " " << t << " " << val << endl;
    } else {
      // Handles correctly whether same[t] existed or not
      same[t].push(val);
      cout << "null" << endl;
    }
  }
}
