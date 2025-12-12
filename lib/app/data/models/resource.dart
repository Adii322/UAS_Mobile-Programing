enum ResourceStatus { initial, loading, success, empty, error }

class Resource<T> {
  const Resource._({
    required this.status,
    this.data,
    this.message,
  });

  final ResourceStatus status;
  final T? data;
  final String? message;

  const Resource.initial() : this._(status: ResourceStatus.initial);

  const Resource.loading([T? data])
      : this._(
          status: ResourceStatus.loading,
          data: data,
        );

  const Resource.success(T data)
      : this._(
          status: ResourceStatus.success,
          data: data,
        );

  const Resource.empty()
      : this._(
          status: ResourceStatus.empty,
        );

  const Resource.error(String message, [T? data])
      : this._(
          status: ResourceStatus.error,
          data: data,
          message: message,
        );

  bool get isLoading => status == ResourceStatus.loading;
  bool get hasData => data != null;
  bool get hasError => status == ResourceStatus.error;
}
