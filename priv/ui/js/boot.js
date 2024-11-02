/**
 * @param {string} path
 */
async function load_component(path) {
  await import(path).then((comp) => {
    console.log("LOG", comp);
  });
}

// console.log(okane);

// window.sprae.effect(() => {
//   console.log("SOME");

// if (window.okane.user === null) {
//   console.log("JE::P");
// }
// });
