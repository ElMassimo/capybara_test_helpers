<script lang="ts">
import { AlgoliaSearchOptions } from 'algoliasearch'
import { useRoute, useRouter } from 'vitepress'
import { getCurrentInstance, onMounted, PropType, watch } from 'vue'

function isSpecialClick (event: MouseEvent) {
  return (
    event.button === 1 ||
    event.altKey ||
    event.ctrlKey ||
    event.metaKey ||
    event.shiftKey
  )
}

function getRelativePath (absoluteUrl: string) {
  const { pathname, hash } = new URL(absoluteUrl)
  // const url = pathname.replace(this.$site.base, '/') + hash
  const url = pathname + hash

  return url
}

export default {
  name: 'AlgoliaSearchBox',

  props: {
    options: {
      type: Object as PropType<AlgoliaSearchOptions>,
      required: true,
    },
  },

  setup (props) {
    const route = useRoute()
    const router = useRouter()
    const vm = getCurrentInstance()

    watch(() => props.options, newValue => { update(newValue) })

    function update (options: any) {
      if (vm && vm.vnode.el) {
        vm.vnode.el.innerHTML = '<div id="docsearch"></div>'
        initialize(options)
      }
    }

    function initialize (userOptions: any) {
      Promise.all([
        import('@docsearch/js'),
        import('@docsearch/css'),
        // import(/* webpackChunkName: "docsearch" */ '@docsearch/js'),
        // Promise.resolve(docsearch),
        // import(/* webpackChunkName: "docsearch" */ '@docsearch/css'),
      ]).then(([docsearch]) => {
        docsearch = docsearch.default

        docsearch(
          Object.assign({}, userOptions, {
            container: '#docsearch',
            // #697 Make DocSearch work well in i18n mode.
            searchParameters: Object.assign(
              {},
              // lang && {
              //   facetFilters: [`lang:${lang}`].concat(
              //     userOptions.facetFilters || []
              //   )
              // },
              userOptions.searchParameters,
            ),
            navigator: {
              navigate: ({ suggestionUrl }: { suggestionUrl: string }) => {
                const { pathname: hitPathname } = new URL(
                  window.location.origin + suggestionUrl,
                )

                // Capybara Test Helpers doesn't handle same-page navigation so we use
                // the native browser location API for anchor navigation.
                if (route.path === hitPathname) {
                  window.location.assign(window.location.origin + suggestionUrl)
                } else {
                  router.go(suggestionUrl)
                }
              },
            },
            transformItems: items => {
              return items.map(item => {
                return Object.assign({}, item, {
                  url: getRelativePath(item.url),
                })
              })
            },
            hitComponent: ({ hit, children }) => {
              const relativeHit = hit.url.startsWith('http')
                ? getRelativePath(hit.url as string)
                : hit.url

              return {
                type: 'a',
                ref: undefined,
                constructor: undefined,
                key: undefined,
                props: {
                  href: hit.url,
                  onClick: (event: MouseEvent) => {
                    if (isSpecialClick(event)) {
                      return
                    }

                    // We rely on the native link scrolling when user is
                    // already on the right anchor because Capybara Test Helpers doesn't
                    // support duplicated history entries.
                    if (route.path === relativeHit) {
                      return
                    }

                    // If the hits goes to another page, we prevent the native link behavior
                    // to leverage the Capybara Test Helpers loading feature.
                    if (route.path !== relativeHit) {
                      event.preventDefault()
                    }

                    router.go(relativeHit)
                  },
                  children,
                },
              }
            },
          }),
        )
      })
    }

    onMounted(() => {
      initialize(props.options)
    })
  },
}
</script>

<template>
  <div id="docsearch"/>
</template>

<style>
.DocSearch {
  --docsearch-primary-color: #DC3008;
  --docsearch-highlight-color: var(--docsearch-primary-color);
  --docsearch-searchbox-shadow: inset 0 0 0 2px var(--docsearch-primary-color);
}
</style>
