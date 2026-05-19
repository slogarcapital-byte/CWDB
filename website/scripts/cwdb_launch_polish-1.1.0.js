(function(){if(window.__cwdbR3FooterFixLoaded)return;window.__cwdbR3FooterFixLoaded=true;function r(f){if(document.readyState!='loading')f();else document.addEventListener('DOMContentLoaded',f)}r(function(){try{
// STEP 1: Repair damage from v1.0.0/1.0.1 which inserted NAP elements *inside* the H4.footer-col-heading (matched [class*="footer-col"]).
document.querySelectorAll('h4.footer-col-heading').forEach(function(h){
  // Pull any accidental P.footer-link and A.footer-link children back out as siblings OR remove if re-injected below
  Array.from(h.querySelectorAll('p.footer-link,a.footer-link,br')).forEach(function(x){x.remove()});
  // Normalize direct text: if H4 textContent has extra after "Contact", clamp
  // (directTextSample showed only "Contact" remained after element removal — OK)
});
// STEP 2: Correct insertion. Find the column div whose heading text === "Contact".
var fw=document.querySelector('.footer-wrap');
if(fw&&fw.getAttribute('data-cwdb-nap-v2')!=='applied'){
  var grid=fw.querySelector('.footer-grid')||fw;
  var contactCol=null;
  Array.from(grid.children).forEach(function(col){
    var h=col.querySelector&&col.querySelector('h4.footer-col-heading,h3,h5');
    if(h&&/^Contact\s*$/i.test(h.textContent.trim()))contactCol=col;
  });
  if(contactCol){
    // Build nodes (textNodes, no innerHTML)
    var addr=document.createElement('p');addr.className='footer-link';
    addr.appendChild(document.createTextNode('906 N 16th Ave'));
    addr.appendChild(document.createElement('br'));
    addr.appendChild(document.createTextNode('Wausau, WI 54401'));
    var em=document.createElement('a');em.className='footer-link';em.setAttribute('href','mailto:info@cwdeckbuilders.com');em.textContent='info@cwdeckbuilders.com';
    // Target 1: Replace the legacy "Central Wisconsin" paragraph (Block 1c) if present
    var legacy=Array.from(contactCol.querySelectorAll('p.footer-link')).find(function(p){return p.textContent.trim()==='Central Wisconsin'});
    if(legacy){legacy.parentNode.insertBefore(addr,legacy);legacy.remove()}else{
      // Insert address right after the heading
      var heading=contactCol.querySelector('h4.footer-col-heading,h3,h5');
      if(heading&&heading.nextSibling)contactCol.insertBefore(addr,heading.nextSibling);
      else contactCol.appendChild(addr);
    }
    // Email: insert after the tel: link if present, else after addr
    var telA=contactCol.querySelector('a[href^="tel:"]');
    var anchor=telA?telA:addr;
    if(anchor.parentNode)anchor.parentNode.insertBefore(em,anchor.nextSibling);
    // Make sure tel href is correct
    if(telA&&telA.getAttribute('href')==='#')telA.setAttribute('href','tel:+17155447941');
  }
  fw.setAttribute('data-cwdb-nap-v2','applied');
}
}catch(e){console.warn('[cwdb-r3-footer]',e)}})})();
