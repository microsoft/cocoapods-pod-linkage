# CocoaPods Pod Linkage plugin

This project is a [CocoaPods](https://github.com/CocoaPods/CocoaPods) plugin that allows to set a `:linkage` option for a specific pod.

CocoaPods doesn't support mixing static and dynamic pods in the same target, you can use `use_frameworks! :linkage => :static` or `use_frameworks! :linkage => :dynamic` to configure the linking style of all pods in a target. This plugin adds support for the `:linkage` option for single pods allowing you to mix static and dynamic linking in the same target.

## Getting started

Install the plugin by adding to your `Gemfile`
```Ruby
gem "cocoapods-pod-linkage"
```

## Usage

Add to your Podfile
```Ruby
plugin 'cocoapods-pod-linkage'
```

Then, use the `:linkage` option to change the linking style of that pod
```Ruby
target :MyTarget do
  use_frameworks! :linkage => :static

  pod 'MyStaticPod', '1.2.3'
  pod 'MyDynamicPod', '1.2.3', :linkage => :dynamic
end
```

## Run tests for this plugin

To run the tests, use
```shell
rake tests
```

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
