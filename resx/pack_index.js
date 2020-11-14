#!/usr/bin/env node

const fs = require('fs');
const stream = require('stream');
const crypto = require('crypto');


const path = __dirname + "/../packages";
console.log('start', path);

let db = {};

const register = function(name, version, os, arch, pkg, path, cb) {
  let vers = version.replace(/\./g, '_').replace(/\-/g, '_')
  os = os.replace(/\-/g, '_')
  if (!db[name]) db[name] = {};
  if (!db[name][os]) db[name][os] = {};
  if (!db[name][os][arch]) db[name][os][arch] = {};

  let key = '000000000000000';

  if (!db[name][os][arch][vers]) db[name][os][arch][vers] = key + '/' + pkg;
  var file = fs.createReadStream(path);
  var hash = crypto.createHash('sha256');
  file.on('data', (data) => {
    hash.update(data);
  })
  file.on('end', () => {
    let sha2 = hash.digest('hex');
    if (db[name][os][arch][vers+'_sha2'] && db[name][os][arch][vers+'_sha2'] != sha2)
      console.warn(`/!\\ Update of checksum for the package ${pkg} (${arch}-${os})`);
    db[name][os][arch][vers+'_sha2'] = sha2
    if (cb)
      cb();
  })
}

const forEachPackage = function(path, act, done) {
  let regex = /(.*)\-(v[0-9]+\.[0-9]+\.[0-9]+(\-[a-z]+)?)\.tar\.(.*)/
  let tasks = 0;
  fs.readdir(path, (err, files) => {
    if (err) throw err;
    tasks += files.length;

    files.forEach(x => {
      let trigram = x.split('-')
      if (trigram.length < 3) {
        --tasks;
        return;
      }
      let arch = trigram.shift();
      let vendor = trigram.shift();
      let os = trigram.join('-')

      let spath = path + '/' + x
      fs.readdir(spath, (err, files) => {
        if (err) throw err;
        tasks += files.length;

        files.forEach(pkg => {
          let m = pkg.match(regex)
          if (m == null) {
            --tasks;
            return;
          }
          let name = m ? m[1] : ''
          let version = m ? m[2] : ''

          act({ name, version, os, arch, file: pkg, path:  spath + '/' + pkg }, () => {
            if (--tasks == 0) {
              done();
            }
          });
        });
        --tasks;
      });
    });

  });
}

const forEachRegisterPackage = function(act, done) {
  for (let name in db) {
    for (let os in db[name]) {
      for (let arch in db[name][os]) {
        act(db[name][os][arch], name, os, arch, () => {

        })
      }
    }
  }
}

const updateLatest = function (pkg) {
  let arr = []
  for (var k in pkg) {
    if (/.*_sha2$/.test(k) || k == 'lastest')
      continue;
    arr.push(k)
  }
  arr = arr.map(x => {
    let m = x.match(/v([0-9]+)_([0-9]+)_([0-9]+)(_.*)?/)
    if (m == null)
      throw new Error('Match failed', x, pkg)
    m.shift();
    return { txt:x, val:m[3] ? 0 : m[0] *1000000 + m[1] * 1000 + m[2] }
  }).sort((a, b) => a.val < b.val ? a : b);
  pkg.lastest = pkg[arr[0].txt]
  pkg.lastest_sha2 = pkg[arr[0].txt + '_sha2']
}

const createYaml = function(data, indent) {
  indent = indent || 0
  let pfx = new Array(indent + 1).join('  ')
  let yaml = ''
  for (var k in data) {
    if (typeof data[k] === 'object')
      yaml += `${pfx}${k}:\n` + createYaml(data[k], indent + 1)
    else
      yaml += `${pfx}${k}: ${data[k]}\n`
    if (indent == 0)
      yaml += '\n'
  }
  return yaml;
}

fs.readFile(path + '/index.json', (err, data) => {
  if (err) throw err;
  db = JSON.parse(data.toString());

  forEachPackage(path, (pkg, cb) => {
    console.log(`Package ${pkg.name} ${pkg.version} for ${pkg.os} ${pkg.arch}: ${pkg.file}`);
    register(pkg.name, pkg.version, pkg.os, pkg.arch, pkg.file, pkg.path, cb)
  }, () => {

    forEachRegisterPackage((pkg, name, os, arch, cb) => {
      updateLatest(pkg)
      cb();
    });


    fs.writeFile(path + '/index.json', JSON.stringify(db, null, 2), (err) => {
      if (err) throw err;
      console.log ('JSON Saved..')
    })

    fs.writeFile(path + '/index.yml', createYaml(db), (err) => {
      if (err) throw err;
      console.log ('YAML Saved..')
    })

  })
})
